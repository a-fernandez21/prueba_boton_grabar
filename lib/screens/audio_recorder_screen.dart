import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/paciente.dart';
import '../controllers/audio_recorder_controller.dart';
import '../widgets/audio_recorder_widgets.dart';
import 'recording_placeholder_screen.dart';

class AudioRecorderScreen extends StatefulWidget {
  final Paciente paciente;
  final String tipoGrabacion;

  const AudioRecorderScreen({
    super.key,
    required this.paciente,
    required this.tipoGrabacion,
  });

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final AudioRecorderController _controller = AudioRecorderController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    _controller.restoreRecordingState();
    _controller.addListener(_onControllerUpdate);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }


  Future<void> _confirmStopRecording() async {
    if (!_controller.isRecording) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar grabación'),
          content: Text(
            '¿Guardar la grabación?\n\n'
            'Duración: ${_controller.formatTime(_controller.seconds)}\n'
            'Marcas: ${_controller.audioMarks.length}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final message = await _controller.stopRecording();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: AppConstants.snackBarDuration,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _addMark() {
    _controller.addMark();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marca añadida en ${_controller.formatTime(_controller.seconds)}',
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _confirmRemoveMark(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar marca'),
          content: Text(
            '¿Eliminar la marca en ${_controller.audioMarks[index]}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _controller.removeMark(index);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marca eliminada'),
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDiscardRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Descartar grabación'),
          content: const Text(
            '¿Estás seguro de que quieres descartar esta grabación?\n\n'
            'Se perderá todo el audio y las marcas creadas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _controller.discardRecording();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación descartada'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  bool _isMinimizing = false;

  void _minimizeRecording() {
    print('📱 Minimizando grabación...');

    // Marcar que estamos minimizando
    _isMinimizing = true;

    // Configurar el overlay ANTES de navegar
    _controller.minimizeRecording(
      context,
      widget.paciente,
      widget.tipoGrabacion,
    );

    print('🔄 Reemplazando con pantalla placeholder');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordingPlaceholderScreen(),
      ),
    );
  }

  void _handleRecordOrPause() {
    if (!_controller.isRecording) {
      _controller.startRecording();
    } else if (_controller.isPaused) {
      _controller.resumeRecording();
    } else {
      _controller.pauseRecording();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);

    // Solo ocultar overlay si NO estamos minimizando
    if (!_isMinimizing) {
      _controller.setOutOfAudioScreen();
    }

    // NO llamar a _controller.dispose() porque es un Singleton
    // y necesitamos mantener el estado cuando minimizamos

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar indicador de carga mientras se restaura el estado
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Column(
        children: [
          RecordingHeader(
            isRecording: _controller.isRecording,
            isPaused: _controller.isPaused,
            seconds: _controller.seconds,
            waveHeights: _controller.waveHeights,
            tipoGrabacion: widget.tipoGrabacion,
            onMinimize: _minimizeRecording,
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 24),

          RecordingControlButtons(
            isRecording: _controller.isRecording,
            isPaused: _controller.isPaused,
            onRecordOrPause: _handleRecordOrPause,
            onStop: _confirmStopRecording,
            onAddMark: _addMark,
            onDiscard: _confirmDiscardRecording,
          ),

          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatientInfoCard(paciente: widget.paciente),
                  const SizedBox(height: 16),
                  AudioMarksList(
                    audioMarks: _controller.audioMarks,
                    onRemoveMark: _confirmRemoveMark,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ActionButton(
              label: 'Ver historia clínica',
              backgroundColor: Colors.orangeAccent,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de historia clínica en desarrollo'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
