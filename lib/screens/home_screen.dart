import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/treino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final dbService = DatabaseService();
    final uid = authService.usuarioAtual?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => context.push('/perfil'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.logout();
              // O redirect do go_router leva para /login automaticamente.
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<List<Treino>>(
              stream: dbService.listarTreinos(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final treinos = snapshot.data ?? [];

                if (treinos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum treino cadastrado.\nToque em + para criar.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: treinos.length,
                  itemBuilder: (context, index) {
                    final treino = treinos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(treino.nome),
                        subtitle: Text(
                          '${treino.exercicioIds.length} exercício(s)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Por enquanto só um aviso — a tela de detalhe
                          // pode ser implementada depois.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Treino: ${treino.nome} '
                                '(${treino.exercicioIds.length} exercícios)',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aqui você pode navegar para o formulário de criação:
          // context.push('/treino-form');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Criar treino — a implementar')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
