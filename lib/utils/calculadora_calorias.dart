class CalculadoraCalorias {
  /// Calcula a queima estimada para uma lista de exercícios
  /// Considerando 10 min por exercício
  static double calcular({
    required double pesoKg,
    required List<double> metsExercicios, //MET: multiplo equivalente metabolico
    double minutosPorExercicio = 10,
  }) {
    double total = 0;
    for (final met in metsExercicios) {
      total += met * pesoKg * (minutosPorExercicio / 60);
    }
    return total;
  }
}
