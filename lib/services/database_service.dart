import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/treino.dart';
import '../models/usuario.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Perfil do usuário (dados de peso/altura) ---
  Future<void> salvarPerfil(Usuario usuario) {
    return _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
  }

  Future<Usuario?> buscarPerfil(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return Usuario.fromMap(uid, doc.data()!);
  }

  // --- CRUD de Treinos (vinculado ao uid) ---
  Future<void> criarTreino(String uid, Treino treino) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('treinos')
        .add(treino.toMap());
  }

  Stream<List<Treino>> listarTreinos(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('treinos')
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Treino.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> atualizarTreino(String uid, Treino treino) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('treinos')
        .doc(treino.id)
        .update(treino.toMap());
  }

  Future<void> deletarTreino(String uid, String treinoId) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('treinos')
        .doc(treinoId)
        .delete();
  }
}
