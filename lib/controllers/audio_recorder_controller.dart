import 'dart:async';
import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../services/audio_recorder_service.dart';
import '../services/recording_overlay_service.dart';

/// Controller que maneja la lógica de grabación de audio (Singleton)
class AudioRecorderController extends ChangeNotifier {
  // Singleton
  static final AudioRecorderController _instance =
      AudioRecorderController._internal();
  factory AudioRecorderController() => _instance;
  AudioRecorderController._internal();

  final AudioRecorderService _audioService = AudioRecorderService();
  final RecordingOverlayService _overlayService = RecordingOverlayService();

  // Estado de grabación
  bool _isRecording = false;
  bool _isPaused = false;
  int _seconds = 0;
  List<double> _waveHeights = List.generate(70, (_) => 0.1);
  List<String> _audioMarks = [];

  // Timer y subscripciones
  Timer? _timer;
  StreamSubscription? _recorderSubscription;
  bool _isInitialized = false;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get seconds => _seconds;
  List<double> get waveHeights => _waveHeights;
  List<String> get audioMarks => _audioMarks;
  AudioRecorderService get audioService => _audioService;
  RecordingOverlayService get overlayService => _overlayService;

  /// Inicializa el controlador (idempotente - se puede llamar varias veces)
  Future<void> initialize() async {
    if (_isInitialized) {
      print('ℹ️ Controller ya inicializado');
      return;
    }

    await _audioService.initialize();
    _overlayService.setAudioService(_audioService);
    _overlayService.setInAudioScreen(true);
    _isInitialized = true;
    print('✅ Controller inicializado');
  }

  /// Restaura el estado de grabación cuando se vuelve a la pantalla
  void restoreRecordingState() {
    if (_overlayService.isRecording) {
      print('🔄 Restaurando estado de grabación...');

      // Marcar que estamos en la pantalla de audio (esto detendrá el timer del overlay)
      _overlayService.setInAudioScreen(true);

      _isRecording = true;
      _isPaused = _overlayService.isPaused;
      _seconds = _overlayService.seconds;
      _audioMarks = List.from(_overlayService.audioMarks);

      // Solo iniciar timer si no hay uno activo
      if (_timer == null) {
        print('⏱️ Iniciando nuevo timer del controller');
        _startTimer();
      } else {
        print('✅ Timer del controller ya activo, no crear uno nuevo');
      }

      // Restaurar las ondas si está grabando activamente
      if (!_isPaused) {
        print('🎵 Restaurando animación de ondas');
        _startWaveAnimation();
      } else {
        print('⏸️ Grabación pausada');
        // Asegurar que las ondas estén en estado bajo
        _waveHeights = List.generate(70, (_) => 0.1);
      }

      notifyListeners();
    }
  }

  /// Inicia el cronómetro
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _seconds++;
        // Sincronizar el overlay con el tiempo actual
        _overlayService.syncTimer(_seconds);
        notifyListeners();
      }
    });
  }

  /// Detiene el cronómetro
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Inicia la animación de ondas
  void _startWaveAnimation() {
    print('🌊 Iniciando animación de ondas...');

    // Si ya hay una subscripción activa, no hacer nada
    if (_recorderSubscription != null) {
      print('ℹ️ Ya existe una subscripción activa al stream');
      return;
    }

    // Dar tiempo al recorder para estar listo
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_audioService.recorder.isRecording) {
        print('⚠️ Recorder no está grabando, reintentando...');
        // Reintentar una vez más si el recorder no está listo
        Future.delayed(const Duration(milliseconds: 300), () {
          _tryStartWaveAnimation();
        });
        return;
      }

      _tryStartWaveAnimation();
    });
  }

  /// Intenta iniciar la animación de ondas
  void _tryStartWaveAnimation() {
    if (!_audioService.recorder.isRecording) {
      print('⚠️ Recorder no está grabando después del retry');
      return;
    }

    final stream = _audioService.recorder.onProgress;
    if (stream == null) {
      print('⚠️ Stream no disponible');
      return;
    }

    print('✅ Iniciando subscripción al stream de audio');

    _recorderSubscription = stream.listen(
      (e) {
        if (!_isPaused) {
          final decibels = e.decibels ?? 0.0;
          double normalizedAmplitude;

          if (decibels <= 45) {
            normalizedAmplitude = 0.05;
          } else if (decibels >= 65) {
            normalizedAmplitude = 1.0;
          } else {
            normalizedAmplitude = 0.05 + ((decibels - 45) / 20) * 0.95;
          }

          _waveHeights.removeAt(0);
          _waveHeights.add(normalizedAmplitude);
          notifyListeners();
        }
      },
      onError: (error) => print('❌ Error en stream: $error'),
      onDone: () => print('🏁 Stream finalizado'),
    );
  }

  /// Detiene la animación de ondas
  void _stopWaveAnimation() {
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    _waveHeights = List.generate(50, (_) => 0.1);
    notifyListeners();
  }

  /// Pausa la animación de ondas (pero mantiene la subscripción)
  void _pauseWaveAnimation() {
    // No cancelar la subscripción, solo actualizar el estado
    // El listener ya tiene el check de !_isPaused
    print('⏸️ Pausando animación de ondas (subscripción activa)');
  }

  /// Formatea el tiempo en HH:MM:SS
  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  /// Inicia la grabación
  Future<void> startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      _isRecording = true;
      _isPaused = false;
      _overlayService.startRecording();
      _startTimer();
      _startWaveAnimation();
      notifyListeners();
    }
  }

  /// Pausa la grabación
  Future<void> pauseRecording() async {
    if (!_isRecording) return;

    await _audioService.pauseRecording();
    _isPaused = true;
    _overlayService.pauseRecording();
    _pauseWaveAnimation();
    notifyListeners();
  }

  /// Reanuda la grabación
  Future<void> resumeRecording() async {
    await _audioService.resumeRecording();
    _isPaused = false;
    _overlayService.resumeRecording();

    // Solo reiniciar animación si no hay subscripción activa
    if (_recorderSubscription == null) {
      print('🔄 Reiniciando animación de ondas al reanudar');
      _startWaveAnimation();
    } else {
      print('✅ Animación de ondas ya activa, solo cambiar estado');
    }

    notifyListeners();
  }

  /// Detiene y guarda la grabación
  Future<String> stopRecording() async {
    if (!_isRecording) return '';

    _stopTimer();
    _stopWaveAnimation();
    final result = await _audioService.stopRecording();
    _overlayService.stopRecording();

    _isRecording = false;
    _isPaused = false;
    _seconds = 0;
    _audioMarks.clear();
    notifyListeners();

    return result.message;
  }

  /// Descarta la grabación
  Future<void> discardRecording() async {
    _stopTimer();
    _stopWaveAnimation();
    await _audioService.stopRecording();

    _isRecording = false;
    _isPaused = false;
    _seconds = 0;
    _audioMarks.clear();
    notifyListeners();
  }

  /// Añade una marca de tiempo
  void addMark() {
    final timeStamp = formatTime(_seconds);
    _audioMarks.add(timeStamp);
    _overlayService.updateAudioMarks(_audioMarks);
    notifyListeners();
  }

  /// Elimina una marca
  void removeMark(int index) {
    _audioMarks.removeAt(index);
    _overlayService.updateAudioMarks(_audioMarks);
    notifyListeners();
  }

  /// Minimiza la pantalla de grabación
  void minimizeRecording(
    BuildContext context,
    Paciente paciente,
    String tipoGrabacion,
  ) {
    _overlayService.setInAudioScreen(
      false,
      context,
      _seconds,
      paciente,
      tipoGrabacion,
      _audioMarks,
    );
  }

  /// Marca que está fuera de la pantalla de audio y oculta el overlay
  void setOutOfAudioScreen() {
    _overlayService.setInAudioScreen(
      true,
    ); // true = estamos en la pantalla, oculta el overlay
    _overlayService.hideOverlay();
  }

  /// Limpia completamente el controller (solo cuando se cierra la grabación definitivamente)
  void cleanup() {
    _stopTimer();
    _stopWaveAnimation();
    _isRecording = false;
    _isPaused = false;
    _seconds = 0;
    _audioMarks.clear();
    _waveHeights = List.generate(70, (_) => 0.1);
    notifyListeners();
  }

  @override
  void dispose() {
    // NO hacer dispose completo aquí porque es un Singleton
    // El cleanup se hace manualmente cuando se detiene la grabación
    super.dispose();
  }
}
