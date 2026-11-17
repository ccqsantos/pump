class Exercicio {
  final String id;
  final String nome;
  final String macroRegiao; // Ex.: 'Superior', 'Inferior', 'Core'
  final String musculo; // Ex.: 'Peito', 'Costas', 'Perna'
  final double met;
  final String gifUrl; // Valor MET para cálculo calórico

  //construtor
  Exercicio({
    required this.id,
    required this.nome,
    required this.macroRegiao,
    required this.musculo,
    required this.met,
    required this.gifUrl,
  });
}
