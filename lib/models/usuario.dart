class Usuario {
  final String uid;
  final String email;
  final double pesoKg;
  final double alturaCm;

  // Construtor
  Usuario({
    required this.uid,
    required this.email,
    required this.pesoKg,
    required this.alturaCm,
  });

  // Map para mandar pro db
  Map<String, dynamic> toMap() => {
    'email': email,
    'pesoKg': pesoKg,
    'alturaCm': alturaCm,
  };

  // "Construtor" do map
  factory Usuario.fromMap(String uid, Map<String, dynamic> map) => Usuario(
    uid: uid,
    email: map['email'] ?? '',
    pesoKg: (map['pesoKg'] ?? 70).toDouble(),
    alturaCm: (map['alturaCm'] ?? 170).toDouble(),
  );
}
