import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/treino.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/catalogo_exercicios.dart';

class TreinoFormScreen extends StatefulWidget {
  final Treino? treino;

  const TreinoFormScreen({super.key, this.treino});

  @override
  State<TreinoFormScreen> createState() => _TreinoFormScreenState();
}

class _TreinoFormScreenState extends State<TreinoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  final _authService = AuthService();
  final _dbService = DatabaseService();

  final Set<String> _exerciciosSelecionados = {};

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.treino != null;

  @override
  void initState() {
    super.initState();

    if (widget.treino != null) {
      _nomeController.text = widget.treino!.nome;
      _exerciciosSelecionados.addAll(widget.treino!.exercicioIds);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _alternarExercicio(String id) {
    setState(() {
      if (_exerciciosSelecionados.contains(id)) {
        _exerciciosSelecionados.remove(id);
      } else {
        _exerciciosSelecionados.add(id);
      }

      _erro = null;
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_exerciciosSelecionados.isEmpty) {
      setState(() {
        _erro = 'Selecione pelo menos um exercício.';
      });
      return;
    }

    final usuario = _authService.usuarioAtual;

    if (usuario == null) {
      setState(() {
        _erro = 'Usuário não autenticado.';
      });
      return;
    }

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final treino = Treino(
        id: widget.treino?.id,
        nome: _nomeController.text.trim(),
        exercicioIds: _exerciciosSelecionados.toList(),
        dataCriacao: widget.treino?.dataCriacao ?? DateTime.now(),
      );

      if (_editando) {
        await _dbService.atualizarTreino(usuario.uid, treino);
      } else {
        await _dbService.criarTreino(usuario.uid, treino);
      }

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      debugPrint('ERRO AO SALVAR TREINO: $e');

      if (mounted) {
        setState(() {
          _erro = 'Não foi possível salvar o treino.';
          _salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final regioes = macroRegioes;

    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar treino' : 'Novo treino')),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do treino',
                        hintText: 'Ex.: Treino A - Peito',
                        prefixIcon: Icon(Icons.fitness_center),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome do treino';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Exercícios',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          '${_exerciciosSelecionados.length} selecionado(s)',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (_erro != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _erro!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),

                    ...regioes.map((macro) {
                      final exercicios = exerciciosPorMacroRegiao(macro);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          initiallyExpanded: true,

                          leading: const Icon(
                            Icons.accessibility_new,
                            color: Colors.orange,
                          ),

                          title: Text(
                            macro,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text('${exercicios.length} exercício(s)'),

                          children: exercicios.map((exercicio) {
                            final selecionado = _exerciciosSelecionados
                                .contains(exercicio.id);

                            return CheckboxListTile(
                              value: selecionado,
                              onChanged: (_) {
                                _alternarExercicio(exercicio.id);
                              },
                              title: Text(
                                exercicio.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${exercicio.musculo} • MET ${exercicio.met}',
                              ),
                              secondary: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  exercicio.gifAsset,
                                  width: 85,
                                  height: 85,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 85,
                                      height: 85,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.fitness_center,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Botão fixo na parte inferior
              Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _salvando ? null : _salvar,

                    icon: _salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),

                    label: Text(
                      _salvando
                          ? 'Salvando...'
                          : _editando
                          ? 'Salvar alterações'
                          : 'Criar treino',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
