import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pump/utils/calculadora_calorias.dart';

import '../models/treino.dart';
import '../models/exercicio.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/catalogo_exercicios.dart';

class TreinoDetalheScreen extends StatefulWidget {
  final Treino treino;

  const TreinoDetalheScreen({super.key, required this.treino});

  @override
  State<TreinoDetalheScreen> createState() => _TreinoDetalheScreenState();
}

class _TreinoDetalheScreenState extends State<TreinoDetalheScreen> {
  // Instãncias para acessar o banco
  final _authService = AuthService();
  final _dbService = DatabaseService();

  // Variáveis que receberão os dados do banco
  Usuario? _usuario;
  List<Exercicio> _exercicios = [];

  // Estados de controle
  bool _loading = true;
  bool _deletando = false;
  String? _erro;

  // Estados de controle
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // Carregar dados inicias da tela
  Future<void> _carregarDados() async {
    final usuarioAtual = _authService.usuarioAtual;

    if (usuarioAtual == null) {
      if (mounted) {
        setState(() {
          _erro = 'Usuário não autenticado.';
          _loading = false;
        });
      }
      return;
    }

    // Tentar buscar no banco
    try {
      final usuario = await _dbService.buscarPerfil(usuarioAtual.uid);

      final exercicios = widget.treino.exercicioIds
          .map(exercicioPorId)
          .whereType<Exercicio>()
          .toList();

      if (!mounted) return;

      setState(() {
        _usuario = usuario;
        _exercicios = exercicios;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ERRO AO CARREGAR DETALHES DO TREINO: $e');

      if (mounted) {
        setState(() {
          _erro = 'Não foi possível carregar o treino.';
          _loading = false;
        });
      }
    }
  }

  // Cálculo do MET (Gasto de calorias estimado)
  double get _caloriasEstimadas {
    final peso = _usuario?.pesoKg;

    if (peso == null || peso <= 0) {
      return 0;
    }

    final mets = _exercicios.map((exercicio) => exercicio.met).toList();

    return CalculadoraCalorias.calcular(pesoKg: peso, metsExercicios: mets);
  }

  // Separa a lista de exercícios por categoria
  Map<String, List<Exercicio>> _agruparExercicios() {
    final grupos = <String, List<Exercicio>>{};

    for (final exercicio in _exercicios) {
      grupos.putIfAbsent(exercicio.macroRegiao, () => []).add(exercicio);
    }

    return grupos;
  }

  // Lógica de exclusão do treino
  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir treino?'),
          content: Text(
            'Tem certeza que deseja excluir o treino '
            '"${widget.treino.nome}"?\n\n'
            'Essa ação não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _deletarTreino();
  }

  // Tentar deletar pelo banco
  Future<void> _deletarTreino() async {
    final usuario = _authService.usuarioAtual;

    if (usuario == null) {
      return;
    }

    setState(() {
      _deletando = true;
    });

    try {
      await _dbService.deletarTreino(usuario.uid, widget.treino.id!);

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      debugPrint('ERRO AO DELETAR TREINO: $e');

      if (!mounted) return;

      setState(() {
        _deletando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o treino.')),
      );
    }
  }

  // Widget auxiliar para carregar o GIF na tela
  Widget _buildGif(Exercicio exercicio) {
    debugPrint('Carregando GIF: ${exercicio.gifAsset}');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        exercicio.gifAsset,
        width: double.infinity,
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Erro ao carregar GIF: $error');

          return const SizedBox(
            height: 220,
            child: Center(child: Text('Não foi possível carregar o GIF')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Exibição de erro
    if (_erro != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do treino')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_erro!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // Agrupando os exercícios por macrorregião
    final grupos = _agruparExercicios();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.treino.nome),
        actions: [
          IconButton(
            tooltip: 'Editar treino',
            icon: const Icon(Icons.edit),
            onPressed: _deletando
                ? null
                : () {
                    context.push('/treino-form', extra: widget.treino);
                  },
          ),
          IconButton(
            tooltip: 'Excluir treino',
            icon: const Icon(Icons.delete),
            onPressed: _deletando ? null : _confirmarExclusao,
          ),
        ],
      ),
      // Lista dos exercícios contidos nesse treino
      // e as informações de queima de calorias.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_caloriasEstimadas.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Queima estimada',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    if (_usuario != null)
                      Text(
                        'Baseado no peso de '
                        '${_usuario!.pesoKg.toStringAsFixed(1)} kg',
                        style: TextStyle(color: Colors.grey.shade700),
                      )
                    else
                      const Text('Perfil de peso não encontrado.'),
                    const SizedBox(height: 3),
                    Text(
                      '${_exercicios.length} exercício(s) • '
                      '${widget.treino.tempoTreino}min de treino ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'em média 10min por exercício - padrão 3 séries de 12',
                      style: TextStyle(
                        fontSize: 8,
                        color: const Color.fromARGB(255, 134, 134, 134),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Exercícios',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (_exercicios.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Nenhum exercício encontrado.')),
                ),
              ),

            // Efetivamente separa por macrorregião corporal
            ...grupos.entries.map((grupo) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: const Icon(
                    Icons.accessibility_new,
                    color: Colors.orange,
                  ),
                  title: Text(
                    grupo.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${grupo.value.length} exercício(s)'),
                  children: grupo.value.map((exercicio) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGif(exercicio),

                          const SizedBox(height: 12),

                          // Título do exercício
                          Text(
                            exercicio.nome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Icon(Icons.accessibility_new, size: 18),
                              const SizedBox(width: 6),
                              Text(exercicio.musculo),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.local_fire_department,
                                size: 18,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text('MET ${exercicio.met}'),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Informação adicional
            Text(
              'A queima de calorias é uma estimativa baseada no seu peso, no MET de cada exercício e em 10 minutos de atividade por exercício.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            if (_deletando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Excluindo treino...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
