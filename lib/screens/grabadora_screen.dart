import 'package:flutter/material.dart';
import 'audio_recorder_screen.dart';
import '../controllers/grabadora_controller.dart';
import '../widgets/audio_recorder_widgets.dart';

class GrabadoraScreen extends StatefulWidget {
  const GrabadoraScreen({super.key});

  @override
  State<GrabadoraScreen> createState() => _GrabadoraScreenState();
}

class _GrabadoraScreenState extends State<GrabadoraScreen> {
  final GrabadoraController _controller = GrabadoraController();

  void _navegarAGrabacion() async {
    if (_controller.puedeComenzarGrabacion) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AudioRecorderScreen(
                paciente: _controller.pacienteSeleccionado!,
                tipoGrabacion: _controller.tipoGrabacionSeleccionado!,
              ),
        ),
      );
    }
  }

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
              selectedPatient: _controller.pacienteSeleccionado,
              patients: _controller.pacientes,
              onChanged: (paciente) {
                setState(() {
                  _controller.seleccionarPaciente(paciente);
                });
              },
            ),

            const SizedBox(height: 32),

            // Selector de tipo de grabación
            RecordingTypeSelector(
              selectedType: _controller.tipoGrabacionSeleccionado,
              enabled: _controller.pacienteSeleccionado != null,
              onTypeSelected: (tipo) {
                setState(() {
                  _controller.seleccionarTipoGrabacion(tipo);
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
                    _controller.puedeComenzarGrabacion
                        ? _navegarAGrabacion
                        : null,
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
