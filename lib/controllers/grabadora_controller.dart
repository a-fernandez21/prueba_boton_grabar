import 'package:flutter/material.dart';
import '../models/paciente.dart';

/// Controller que maneja la lógica de la pantalla de selección de grabación
class GrabadoraController extends ChangeNotifier {
  Paciente? _pacienteSeleccionado;
  String? _tipoGrabacionSeleccionado;

  // Lista de pacientes (en una app real vendría de una base de datos)
  final List<Paciente> _pacientes = [
    Paciente(id: '001', nombre: 'Juan', apellidos: 'García Pérez', edad: 45),
    Paciente(id: '002', nombre: 'María', apellidos: 'López Martínez', edad: 38),
    Paciente(
      id: '003',
      nombre: 'Carlos',
      apellidos: 'Rodríguez Sánchez',
      edad: 52,
    ),
    Paciente(id: '004', nombre: 'Ana', apellidos: 'Fernández Gómez', edad: 29),
    Paciente(id: '005', nombre: 'Pedro', apellidos: 'Martín Ruiz', edad: 61),
    Paciente(id: '006', nombre: 'Laura', apellidos: 'Jiménez Torres', edad: 34),
    Paciente(id: '007', nombre: 'Roberto', apellidos: 'Díaz Moreno', edad: 47),
    Paciente(id: '008', nombre: 'Carmen', apellidos: 'Muñoz Álvarez', edad: 56),
  ];

  // Getters
  Paciente? get pacienteSeleccionado => _pacienteSeleccionado;
  String? get tipoGrabacionSeleccionado => _tipoGrabacionSeleccionado;
  List<Paciente> get pacientes => _pacientes;

  /// Verifica si se puede iniciar la grabación
  bool get puedeComenzarGrabacion =>
      _pacienteSeleccionado != null && _tipoGrabacionSeleccionado != null;

  /// Selecciona un paciente
  void seleccionarPaciente(Paciente? paciente) {
    _pacienteSeleccionado = paciente;
    notifyListeners();
  }

  /// Selecciona el tipo de grabación
  void seleccionarTipoGrabacion(String tipo) {
    _tipoGrabacionSeleccionado = tipo;
    notifyListeners();
  }

  /// Reinicia la selección
  void reiniciarSeleccion() {
    _pacienteSeleccionado = null;
    _tipoGrabacionSeleccionado = null;
    notifyListeners();
  }
}
