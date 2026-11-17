import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioAtual => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  StreamSubscription<User?>? _authSubscription;

  AuthService() {
    _authSubscription = _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  Future<UserCredential> cadastrar(String email, String senha) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw _traduzErro(e);
    }
  }

  Future<UserCredential> login(String email, String senha) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw _traduzErro(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _traduzErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';

      case 'wrong-password':
        return 'Senha incorreta.';

      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';

      case 'email-already-in-use':
        return 'E-mail já cadastrado.';

      case 'invalid-email':
        return 'E-mail inválido.';

      case 'weak-password':
        return 'A senha é muito fraca.';

      case 'operation-not-allowed':
        return 'Login por e-mail e senha não está habilitado no Firebase.';

      case 'network-request-failed':
        return 'Erro de conexão com o Firebase.';

      default:
        return 'Erro: ${e.message ?? e.code}';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
