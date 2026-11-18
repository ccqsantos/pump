import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/treino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instãncias para acessar o banco
    final authService = AuthService();
    final dbService = DatabaseService();
    final uid = authService.usuarioAtual?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
        actions: [
          //Botão do Perfil
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => context.push('/perfil'),
          ),

          //Botão de Logout
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
          // Validação para garantir que o usuário não está acessando essa tela sem estar logado.
          ? const Center(child: Text('Usuário não autenticado'))
          : StreamBuilder<List<Treino>>(
              // Renderiza como Stream os dados de listarTreinos() do banco.
              stream: dbService.listarTreinos(uid),
              // Snapshot: traz dados. Context: envia dados.
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final treinos = snapshot.data ?? [];

                // Tratamento de erro
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
                          context.push('/treino-detalhe', extra: treino);
                        },
                      ),
                    );
                  },
                );
              },
            ),
      // Botão para ir para treino_form_screen
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/treino-form'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
