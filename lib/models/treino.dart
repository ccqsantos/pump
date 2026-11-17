class Treino {
  final String? id;
  final String nome;
  final List<String> exercicioIds;
  final DateTime dataCriacao;

  // Construtor
  Treino({
    this.id,
    required this.nome,
    required this.exercicioIds,
    required this.dataCriacao,
  });

  // Map para mandar pro db
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'exercicioIds': exercicioIds,
    'dataCriacao': dataCriacao.toIso8601String(),
  };

  // "Construtor" do map
  factory Treino.fromMap(String id, Map<String, dynamic> map) => Treino(
    id: id,
    nome: map['nome'] ?? '',
    exercicioIds: List<String>.from(map['exercicioIds'] ?? []),
    dataCriacao: DateTime.parse(
      map['dataCriacao'] ?? DateTime.now().toIso8601String(),
    ),
  );
}
