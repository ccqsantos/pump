class Treino {
  final String? id;
  final String nome;
  final int tempoTreino;
  final List<String> exercicioIds;
  final DateTime dataCriacao;

  Treino({
    this.id,
    required this.nome,
    required this.exercicioIds,
    required this.dataCriacao,
    required this.tempoTreino,
  });

  // Map para mandar pro db
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'exercicioIds': exercicioIds,
    'dataCriacao': dataCriacao.toIso8601String(),
    'tempoTreino': tempoTreino,
  };

  // "Construtor" do map
  factory Treino.fromMap(String id, Map<String, dynamic> map) => Treino(
    id: id,
    nome: map['nome'] ?? '',
    exercicioIds: List<String>.from(map['exercicioIds'] ?? []),
    dataCriacao: DateTime.parse(
      map['dataCriacao'] ?? DateTime.now().toIso8601String(),
    ),
    tempoTreino: map['tempoTreino'] ?? 0,
  );
}
