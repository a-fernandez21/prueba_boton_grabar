import 'package:flutter/material.dart';
import 'audio_recorder_screen.dart';
import 'recording_placeholder_screen.dart';
import '../models/paciente.dart';

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

            // Dropdown
            const Text(
              'Seleccione un paciente',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Paciente>(
              value: _pacienteSeleccionado,
              dropdownColor: Colors.white,
              items:
                  _pacientes.map((paciente) {
                    return DropdownMenuItem<Paciente>(
                      value: paciente,
                      child: Text(paciente.displayText),
                    );
                  }).toList(),
              onChanged: (Paciente? nuevoPaciente) {
                setState(() {
                  _pacienteSeleccionado = nuevoPaciente;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.lightBlueAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.lightBlueAccent,
                    width: 2,
                  ),
                ),
                hintText: 'Seleccionar paciente...',
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Seleccione el tipo de grabación:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Botón 1 - Nueva anamnesis (selector)
            OutlinedButton(
              onPressed:
                  _pacienteSeleccionado == null
                      ? null
                      : () {
                        setState(() {
                          _tipoGrabacionSeleccionado = 'Nueva anamnesis';
                        });
                      },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor:
                    _tipoGrabacionSeleccionado == 'Nueva anamnesis'
                        ? Colors.lightBlueAccent.withOpacity(0.1)
                        : Colors.white,
                side: BorderSide(
                  color:
                      _pacienteSeleccionado == null
                          ? Colors.grey
                          : (_tipoGrabacionSeleccionado == 'Nueva anamnesis'
                              ? Colors.lightBlueAccent
                              : Colors.lightBlueAccent.withOpacity(0.5)),
                  width:
                      _tipoGrabacionSeleccionado == 'Nueva anamnesis' ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_tipoGrabacionSeleccionado == 'Nueva anamnesis')
                    const Icon(
                      Icons.check_circle,
                      color: Colors.lightBlueAccent,
                      size: 20,
                    ),
                  if (_tipoGrabacionSeleccionado == 'Nueva anamnesis')
                    const SizedBox(width: 8),
                  Text(
                    'Nueva anamnesis',
                    style: TextStyle(
                      color:
                          _pacienteSeleccionado == null
                              ? Colors.grey
                              : Colors.lightBlueAccent,
                      fontWeight:
                          _tipoGrabacionSeleccionado == 'Nueva anamnesis'
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Botón 2 - Nuevo seguimiento (selector)
            OutlinedButton(
              onPressed:
                  _pacienteSeleccionado == null
                      ? null
                      : () {
                        setState(() {
                          _tipoGrabacionSeleccionado = 'Nuevo seguimiento';
                        });
                      },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor:
                    _tipoGrabacionSeleccionado == 'Nuevo seguimiento'
                        ? Colors.lightBlueAccent.withOpacity(0.1)
                        : Colors.white,
                side: BorderSide(
                  color:
                      _pacienteSeleccionado == null
                          ? Colors.grey
                          : (_tipoGrabacionSeleccionado == 'Nuevo seguimiento'
                              ? Colors.lightBlueAccent
                              : Colors.lightBlueAccent.withOpacity(0.5)),
                  width:
                      _tipoGrabacionSeleccionado == 'Nuevo seguimiento' ? 2 : 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_tipoGrabacionSeleccionado == 'Nuevo seguimiento')
                    const Icon(
                      Icons.check_circle,
                      color: Colors.lightBlueAccent,
                      size: 20,
                    ),
                  if (_tipoGrabacionSeleccionado == 'Nuevo seguimiento')
                    const SizedBox(width: 8),
                  Text(
                    'Nuevo seguimiento',
                    style: TextStyle(
                      color:
                          _pacienteSeleccionado == null
                              ? Colors.grey
                              : Colors.lightBlueAccent,
                      fontWeight:
                          _tipoGrabacionSeleccionado == 'Nuevo seguimiento'
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ],
              ),
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
