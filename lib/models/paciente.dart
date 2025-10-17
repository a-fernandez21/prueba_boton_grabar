/// Modelo de datos para un paciente
class Paciente {
  final String id;
  final String nombre;
  final String apellidos;
  final int edad;

  Paciente({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.edad,
  });

  /// Nombre completo del paciente
  String get nombreCompleto => '$nombre $apellidos';

  /// Texto para mostrar en el dropdown
  String get displayText => '$nombreCompleto ($edad años)';
}
