import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/paciente.dart';
import '../services/audio_recorder_service.dart';
import '../services/recording_overlay_service.dart';
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
  bool _isRecording = false;
  bool _isPaused = false;
  final AudioRecorderService _audioService = AudioRecorderService();
  final RecordingOverlayService _overlayService = RecordingOverlayService();

  // Cronómetro
  int _seconds = 0;
  Timer? _timer;

  // Visualizador de ondas basado en amplitud real
  StreamSubscription? _recorderSubscription;
  List<double> _waveHeights = List.generate(70, (_) => 0.1);

  // Marcas en el audio
  List<String> _audioMarks = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _overlayService.setInAudioScreen(true);

    // Restaurar el estado si ya hay una grabación en curso
    _restoreRecordingState();
  }

  Future<void> _initRecorder() async {
    await _audioService.initialize();
    _overlayService.setAudioService(_audioService);
  }

  void _restoreRecordingState() {
    // Si el servicio de overlay indica que hay una grabación en curso, restaurar el estado
    if (_overlayService.isRecording) {
      print('🔄 Restaurando estado de grabación...');
      print(
        '📊 Estado del recorder: isRecording=${_audioService.recorder.isRecording}, isPaused=${_audioService.recorder.isPaused}',
      );

      setState(() {
        _isRecording = true;
        _isPaused = _overlayService.isPaused;
        _seconds = _overlayService.seconds;
        _audioMarks = List.from(_overlayService.audioMarks);
      });

      // SIEMPRE iniciar el timer (el timer ya verifica _isPaused internamente)
      print('⏱️ Iniciando timer (verifica pausado internamente)');
      _startTimer();

      // Solo iniciar animación de ondas si NO está pausado
      if (!_isPaused) {
        print('▶️ Iniciando animación de ondas (no pausado)');
        _startWaveAnimation();
      } else {
        print('⏸️ Estado pausado - no iniciar animación');
      }

      print(
        '✅ Estado restaurado: grabando=$_isRecording, pausado=$_isPaused, segundos=$_seconds, marcas=${_audioMarks.length}',
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startWaveAnimation() {
    print('🌊 Intentando iniciar animación de ondas...');
    print(
      '📊 Recorder state: isRecording=${_audioService.recorder.isRecording}, isPaused=${_audioService.recorder.isPaused}',
    );

    // Cancelar cualquier suscripción anterior
    if (_recorderSubscription != null) {
      print('🔄 Cancelando suscripción anterior...');
      _recorderSubscription?.cancel();
      _recorderSubscription = null;
    }

    // Verificar que el recorder esté grabando
    if (!_audioService.recorder.isRecording) {
      print('⚠️ Recorder no está grabando - no se puede iniciar animación');
      return;
    }

    // Verificar que el recorder tenga el stream disponible
    final stream = _audioService.recorder.onProgress;
    if (stream == null) {
      print('⚠️ Stream de progreso no disponible');
      return;
    }

    print('✅ Stream disponible, creando suscripción...');

    // Suscribirse al stream de amplitud del grabador
    _recorderSubscription = stream.listen(
      (e) {
        if (!_isPaused && mounted) {
          // flutter_sound reporta valores POSITIVOS en el rango 0-120 dB
          // donde valores bajos = silencio y valores altos = sonido fuerte
          final decibels = e.decibels ?? 0.0;

          // Normalizar a un rango de 0.05 a 1.0 usando la escala positiva
          // 0-45 dB = silencio/ruido ambiente → 0.05 (ondas casi invisibles)
          // 65+ dB = voz muy fuerte → 1.0 (ondas al máximo)
          double normalizedAmplitude;

          if (decibels <= 45) {
            // Silencio o ruido ambiente bajo
            normalizedAmplitude = 0.05;
          } else if (decibels >= 65) {
            // Voz fuerte
            normalizedAmplitude = 1.0;
          } else {
            // Interpolación lineal entre 45 y 65 dB (rango de 20 dB)
            normalizedAmplitude = 0.05 + ((decibels - 45) / 20) * 0.95;
          }

          // Debug detallado (solo cada 10 eventos para no saturar)
          if (_waveHeights.length % 10 == 0) {
            print(
              '🎤 dB: $decibels → Amplitud: ${normalizedAmplitude.toStringAsFixed(2)} → Altura: ${(60 * normalizedAmplitude).toStringAsFixed(1)}px',
            );
          }

          setState(() {
            // Rotar las ondas y agregar la nueva amplitud
            _waveHeights.removeAt(0);
            _waveHeights.add(normalizedAmplitude);
          });
        }
      },
      onError: (error) {
        print('❌ Error en stream de ondas: $error');
      },
      onDone: () {
        print('🏁 Stream de ondas finalizado');
      },
    );

    print('✅ Suscripción a ondas completada');
  }

  void _stopWaveAnimation() {
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    setState(() {
      // Resetear ondas a silencio
      _waveHeights = List.generate(50, (_) => 0.1);
    });
  }

  void _pauseWaveAnimation() {
    // Cancelar suscripción cuando está pausado, pero mantener las ondas visibles
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    // NO resetear _waveHeights ni _currentAmplitude para mantener el estado visual
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
      _overlayService.startRecording();
      _startTimer();
      _startWaveAnimation();
    }
  }

  Future<void> _pauseRecording() async {
    if (!_isRecording) return; // No pausar si no está grabando
    await _audioService.pauseRecording();
    setState(() {
      _isPaused = true;
    });
    _overlayService.pauseRecording();
    _pauseWaveAnimation();
  }

  Future<void> _resumeRecording() async {
    await _audioService.resumeRecording();
    setState(() {
      _isPaused = false;
    });
    _overlayService.resumeRecording();
    _startWaveAnimation();
  }

  Future<void> _confirmStopRecording() async {
    if (!_isRecording) return; // No detener si no está grabando

    _stopTimer();
    _stopWaveAnimation();
    final result = await _audioService.stopRecording();
    _overlayService.stopRecording();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Guardar grabación'),
          content: Text(
            '¿Guardar la grabación?\n\n'
            'Duración: ${_formatTime(_seconds)}\n'
            'Marcas: ${_audioMarks.length}',
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
      _stopTimer();
      _stopWaveAnimation();
      await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _seconds = 0;
        _audioMarks.clear(); // Limpiar marcas al guardar
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            duration: AppConstants.snackBarDuration,
          ),
        );

        // Volver a la pantalla anterior después de detener
        Navigator.pop(context);
      }
    }
  }

  void _addMark() {
    // Añadir marca en el tiempo actual
    final String timeStamp = _formatTime(_seconds);
    setState(() {
      _audioMarks.add(timeStamp);
    });

    // Actualizar marcas en el servicio
    _overlayService.updateAudioMarks(_audioMarks);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marca añadida en $timeStamp'),
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
          content: Text('¿Eliminar la marca en ${_audioMarks[index]}?'),
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
      setState(() {
        _audioMarks.removeAt(index);
      });

      // Actualizar marcas en el servicio
      _overlayService.updateAudioMarks(_audioMarks);

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
      // Detener la grabación sin guardar
      _stopTimer();
      _stopWaveAnimation();
      await _audioService.stopRecording();

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _seconds = 0;
        _audioMarks.clear(); // Limpiar marcas
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grabación descartada'),
            duration: Duration(seconds: 2),
          ),
        );

        // Volver a la pantalla anterior
        Navigator.pop(context);
      }
    }
  }

  void _minimizeRecording() {
    print('📱 Minimizando grabación...');

    // Marcar que salimos de la pantalla de audio y pasar el tiempo actual Y LAS MARCAS
    _overlayService.setInAudioScreen(
      false,
      context,
      _seconds,
      widget.paciente,
      widget.tipoGrabacion,
      _audioMarks,
    );

    print('🔄 Reemplazando con pantalla placeholder');
    // Reemplazar la pantalla actual con la placeholder
    // Esto mantiene el widget flotante visible y la grabación activa
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordingPlaceholderScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _stopWaveAnimation();
    _overlayService.setInAudioScreen(false);
    _overlayService.hideOverlay();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sección superior usando RecordingHeader
          RecordingHeader(
            isRecording: _isRecording,
            isPaused: _isPaused,
            seconds: _seconds,
            waveHeights: _waveHeights,
            tipoGrabacion: widget.tipoGrabacion,
            onMinimize: _minimizeRecording,
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          const SizedBox(height: 24),

          // Botones de control
          RecordingControlButtons(
            isRecording: _isRecording,
            isPaused: _isPaused,
            onRecordOrPause: () {
              if (!_isRecording) {
                _startRecording();
              } else if (_isPaused) {
                _resumeRecording();
              } else {
                _pauseRecording();
              }
            },
            onStop: _confirmStopRecording,
            onAddMark: _addMark,
            onDiscard: _confirmDiscardRecording,
          ),

          const SizedBox(height: 32),

          // Área scrollable con ficha del paciente y marcas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatientInfoCard(paciente: widget.paciente),
                  const SizedBox(height: 16),
                  AudioMarksList(
                    audioMarks: _audioMarks,
                    onRemoveMark: _confirmRemoveMark,
                  ),
                ],
              ),
            ),
          ),

          // Botón historia clínica
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
