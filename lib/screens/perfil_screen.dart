import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  final _authService = AuthService();
  final _dbService = DatabaseService();

  Usuario? _usuario;
  bool _loading = true;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    final uid = _authService.usuarioAtual?.uid;
    if (uid == null) return;

    try {
      final usuario = await _dbService.buscarPerfil(uid);
      if (usuario != null) {
        _usuario = usuario;
        _pesoController.text = usuario.pesoKg.toString();
        _alturaController.text = usuario.alturaCm.toString();
      }
    } catch (e) {
      debugPrint('ERRO AO CARREGAR PERFIL: $e');
      _erro = 'Não foi possível carregar o perfil.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final uid = _authService.usuarioAtual!.uid;
      final usuarioAtualizado = Usuario(
        uid: uid,
        email: _usuario?.email ?? _authService.usuarioAtual!.email ?? '',
        pesoKg: double.parse(_pesoController.text.replaceAll(',', '.')),
        alturaCm: double.parse(_alturaController.text.replaceAll(',', '.')),
      );
      await _dbService.salvarPerfil(usuarioAtualizado);
      if (mounted) {
        setState(() => _usuario = usuarioAtualizado);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
      }
    } catch (e) {
      debugPrint('ERRO AO SALVAR PERFIL: $e');
      if (mounted)
        setState(() => _erro = 'Não foi possível salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _deletarConta() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir conta?'),
          content: const Text(
            'Esta ação excluirá sua conta, seu perfil e todos os seus treinos. '
            'Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      final uid = _authService.usuarioAtual?.uid;

      if (uid == null) {
        throw Exception('Usuário não autenticado.');
      }

      // 1. Apaga perfil + treinos do Firestore
      await _dbService.deletarPerfil(uid);

      // 2. Apaga a conta do Firebase Authentication
      await _authService.deletarConta();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso.')),
      );

      // O AuthService / GoRouter deve detectar o logout
      // e redirecionar para /login.
    } on FirebaseAuthException catch (e) {
      debugPrint('ERRO AO EXCLUIR CONTA: ${e.code}');

      if (!mounted) return;

      setState(() {
        _salvando = false;
      });

      String mensagem;

      if (e.code == 'requires-recent-login') {
        mensagem =
            'Por segurança, faça login novamente antes de excluir sua conta.';
      } else {
        mensagem = 'Não foi possível excluir a conta.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (e) {
      debugPrint('ERRO AO EXCLUIR CONTA: $e');

      if (!mounted) return;

      setState(() {
        _salvando = false;
        _erro = 'Não foi possível excluir a conta. Tente novamente.';
      });
    }
  }

  double? get _imc {
    if (_usuario == null) return null;
    final alturaM = _usuario!.alturaCm / 100;
    if (alturaM <= 0) return null;
    return _usuario!.pesoKg / (alturaM * alturaM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 72,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _usuario?.email ??
                              _authService.usuarioAtual?.email ??
                              '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),

                        if (_imc != null) ...[
                          Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    'IMC: ${_imc!.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Peso: ${_usuario!.pesoKg} kg  •  '
                                    'Altura: ${_usuario!.alturaCm} cm',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        TextFormField(
                          controller: _pesoController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Peso (kg)',
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Informe o peso';
                            final peso = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (peso == null || peso <= 0)
                              return 'Peso inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _alturaController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Altura (cm)',
                            prefixIcon: Icon(Icons.height),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Informe a altura';
                            final altura = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (altura == null || altura <= 0)
                              return 'Altura inválida';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        if (_erro != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _erro!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _salvando ? null : _salvar,
                            child: _salvando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text('Salvar'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () async {
                            await _authService.logout();
                            // O redirect do go_router leva para /login.
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sair'),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: _salvando ? null : _deletarConta,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Excluir minha conta'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
