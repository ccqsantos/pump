import '../models/exercicio.dart';

final List<Exercicio> catalogoExercicios = [
  // ===================== SUPERIOR =====================
  // Peito
  Exercicio(
    id: 'sup_peito_01',
    nome: 'Supino reto',
    macroRegiao: 'Superior',
    musculo: 'Peito',
    met: 3.5,
    gifAsset: 'assets/exercises/barbell-bench-press.gif',
  ),
  Exercicio(
    id: 'sup_peito_02',
    nome: 'Crucifixo',
    macroRegiao: 'Superior',
    musculo: 'Peito',
    met: 3.0,
    gifAsset: 'assets/exercises/dumbbell-fly.gif',
  ),
  // Costas
  Exercicio(
    id: 'sup_costas_01',
    nome: 'Puxada na frente',
    macroRegiao: 'Superior',
    musculo: 'Costas',
    met: 3.5,
    gifAsset: 'assets/exercises/cable-pulldown.gif',
  ),
  Exercicio(
    id: 'sup_costas_02',
    nome: 'Remada curvada',
    macroRegiao: 'Superior',
    musculo: 'Costas',
    met: 4.0,
    gifAsset: 'assets/exercises/dumbbell-bent-over-row.gif',
  ),
  // Ombros
  Exercicio(
    id: 'sup_ombro_01',
    nome: 'Desenvolvimento militar',
    macroRegiao: 'Superior',
    musculo: 'Ombros',
    met: 3.5,
    gifAsset: 'assets/exercises/desenvolvimento-militar.gif',
  ),
  // Bíceps
  Exercicio(
    id: 'sup_biceps_01',
    nome: 'Rosca direta',
    macroRegiao: 'Superior',
    musculo: 'Bíceps',
    met: 3.0,
    gifAsset: 'assets/exercises/dumbbell-biceps-curl.gif',
  ),

  // ===================== INFERIOR =====================
  // Pernas (quadríceps)
  Exercicio(
    id: 'inf_perna_01',
    nome: 'Agachamento livre',
    macroRegiao: 'Inferior',
    musculo: 'Pernas',
    met: 5.0,
    gifAsset: 'assets/exercises/barbell-high-bar-squat.gif',
  ),
  Exercicio(
    id: 'inf_perna_02',
    nome: 'Leg press',
    macroRegiao: 'Inferior',
    musculo: 'Pernas',
    met: 4.0,
    gifAsset: 'assets/exercises/legpress45-leg-press.gif',
  ),
  // Glúteos
  Exercicio(
    id: 'inf_gluteo_01',
    nome: 'Elevação pélvica',
    macroRegiao: 'Inferior',
    musculo: 'Glúteos',
    met: 3.5,
    gifAsset: 'assets/exercises/elevacao-pelvica-no-banco.gif',
  ),
  // Panturrilha
  Exercicio(
    id: 'inf_panturrilha_01',
    nome: 'Panturrilha em pé',
    macroRegiao: 'Inferior',
    musculo: 'Panturrilha',
    met: 3.0,
    gifAsset: 'assets/exercises/lever-standing-calf-raise.gif',
  ),

  // ===================== CORE =====================
  // Abdômen
  Exercicio(
    id: 'core_abdomen_01',
    nome: 'Prancha',
    macroRegiao: 'Core',
    musculo: 'Abdômen',
    met: 3.0,
    gifAsset: 'assets/exercises/prancha.jpg',
  ),
  Exercicio(
    id: 'core_abdomen_02',
    nome: 'Abdominal supra',
    macroRegiao: 'Core',
    musculo: 'Abdômen',
    met: 3.0,
    gifAsset: 'assets/exercises/47271301-abdominal-supra.gif',
  ),
  // Lombar
  Exercicio(
    id: 'core_lombar_01',
    nome: 'Extensão lombar',
    macroRegiao: 'Core',
    musculo: 'Lombar',
    met: 2.5,
    gifAsset: 'assets/exercises/full-stretch-for-hyperextension.gif',
  ),
];

/// Retorna as macro-regiões únicas, na ordem desejada.
List<String> get macroRegioes {
  final set = <String>{};
  for (final e in catalogoExercicios) {
    set.add(e.macroRegiao);
  }
  return set.toList();
}

/// Retorna os exercícios de uma macro-região.
List<Exercicio> exerciciosPorMacroRegiao(String macro) {
  return catalogoExercicios.where((e) => e.macroRegiao == macro).toList();
}

/// Retorna os músculos únicos dentro de uma macro-região.
List<String> musculosPorMacroRegiao(String macro) {
  final set = <String>{};
  for (final e in catalogoExercicios.where((e) => e.macroRegiao == macro)) {
    set.add(e.musculo);
  }
  return set.toList();
}

/// Retorna os exercícios de um músculo específico dentro de uma macro-região.
List<Exercicio> exerciciosPorMusculo(String macro, String musculo) {
  return catalogoExercicios
      .where((e) => e.macroRegiao == macro && e.musculo == musculo)
      .toList();
}

/// Busca um exercício pelo id (usado ao abrir um treino salvo).
Exercicio? exercicioPorId(String id) {
  for (final e in catalogoExercicios) {
    if (e.id == id) return e;
  }
  return null;
}
