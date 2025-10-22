import 'package:flutter/material.dart';
import 'audio_recorder_screen.dart';
import '../models/paciente.dart';
import '../widgets/recording_widgets.dart';

class GrabadoraScreen extends StatefulWidget {
  const GrabadoraScreen({super.key});

  @override
  State<GrabadoraScreen> createState() => _GrabadoraScreenState();
}

class _GrabadoraScreenState extends State<GrabadoraScreen> {
  Paciente? _pacienteSeleccionado;
  String? _tipoGrabacionSeleccionado;

  void _navegarAGrabacion() async {
    if (_pacienteSeleccionado != null && _tipoGrabacionSeleccionado != null) {
      // Navegar a la pantalla de grabación
      // El placeholder se mostrará automáticamente cuando se minimice
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AudioRecorderScreen(
                paciente: _pacienteSeleccionado!,
                tipoGrabacion: _tipoGrabacionSeleccionado!,
              ),
        ),
      );
    }
  }

  // Lista de pacientes de ejemplo
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan),
              child: Text(
                'Fisiomap',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Grabadora inteligente'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(''),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grabadora',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Selector de paciente
            PatientSelector(
              selectedPatient: _pacienteSeleccionado,
              patients: _pacientes,
              onChanged: (Paciente? nuevoPaciente) {
                setState(() {
                  _pacienteSeleccionado = nuevoPaciente;
                });
              },
            ),

            const SizedBox(height: 32),

            // Selector de tipo de grabación
            RecordingTypeSelector(
              selectedType: _tipoGrabacionSeleccionado,
              enabled: _pacienteSeleccionado != null,
              onTypeSelected: (String tipo) {
                setState(() {
                  _tipoGrabacionSeleccionado = tipo;
                });
              },
            ),

            const Spacer(),

            // Botón para ir a la pantalla de grabación
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    (_pacienteSeleccionado == null ||
                            _tipoGrabacionSeleccionado == null)
                        ? null
                        : _navegarAGrabacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Comenzar a grabar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
