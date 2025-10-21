import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_recorder_service.dart';
import '../models/paciente.dart';
import '../screens/audio_recorder_screen.dart';

class RecordingOverlayService {
  static final RecordingOverlayService _instance =
      RecordingOverlayService._internal();
  factory RecordingOverlayService() => _instance;
  RecordingOverlayService._internal();

  OverlayEntry? _overlayEntry;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isInAudioScreen = false;
  AudioRecorderService? _audioService;
  int _seconds = 0;
  Timer? _timer;
  Paciente? _paciente;
  String? _tipoGrabacion;
  List<String> _audioMarks = [];

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get seconds => _seconds;
  List<String> get audioMarks => _audioMarks;

  void setAudioService(AudioRecorderService audioService) {
    _audioService = audioService;
  }

  void syncTimer(int seconds) {
    _seconds = seconds;
    _overlayEntry?.markNeedsBuild();
  }

  void _startOverlayTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        _seconds++;
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _stopOverlayTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void setInAudioScreen(
    bool inAudioScreen, [
    BuildContext? context,
    int? currentSeconds,
    Paciente? paciente,
    String? tipoGrabacion,
    List<String>? audioMarks,
  ]) {
    _isInAudioScreen = inAudioScreen;
    if (inAudioScreen) {
      hideOverlay();
    } else if (_isRecording && context != null) {
      if (currentSeconds != null) {
        _seconds = currentSeconds;
      }
      // Guardar los datos del paciente y tipo de grabación para poder navegar de vuelta
      if (paciente != null) {
        _paciente = paciente;
      }
      if (tipoGrabacion != null) {
        _tipoGrabacion = tipoGrabacion;
      }
      // Guardar las marcas de audio
      if (audioMarks != null) {
        _audioMarks = List.from(audioMarks);
      }
      showOverlay(context);
      // Iniciar el timer del overlay cuando se minimiza
      _startOverlayTimer();
    }
  }

  void showOverlay(BuildContext? context) {
    if (_overlayEntry != null || _isInAudioScreen || context == null) return;

    _overlayEntry = OverlayEntry(
      builder:
          (overlayContext) => Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: const _FloatingRecordingWidget(),
          ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _stopOverlayTimer();
    // NO resetear _isRecording ni _isPaused aquí
    // Esos estados se resetean solo cuando se detiene la grabación completamente
  }

  void startRecording() {
    _isRecording = true;
    _isPaused = false;
    _overlayEntry?.markNeedsBuild();
  }

  void updateAudioMarks(List<String> marks) {
    _audioMarks = List.from(marks);
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  void stopRecording() {
    _isRecording = false;
    _isPaused = false;
    _stopOverlayTimer();
    _seconds = 0;
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> pauseRecording() async {
    if (_audioService != null) {
      await _audioService!.pauseRecording();
    }
    _isPaused = true;
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> resumeRecording() async {
    if (_audioService != null) {
      await _audioService!.resumeRecording();
    }
    _isPaused = false;
    _overlayEntry?.markNeedsBuild();
  }

  Future<void> stopRecordingFromOverlay() async {
    if (_audioService != null) {
      await _audioService!.stopRecording();
    }
    stopRecording();
    hideOverlay();
  }
}

class _FloatingRecordingWidget extends StatefulWidget {
  const _FloatingRecordingWidget();

  @override
  State<_FloatingRecordingWidget> createState() =>
      _FloatingRecordingWidgetState();
}

class _FloatingRecordingWidgetState extends State<_FloatingRecordingWidget>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  List<double> _waveHeights = List.generate(8, (_) => 0.1);

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = RecordingOverlayService();

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        // Actualizar alturas de ondas solo si está grabando y no pausado
        if (service.isRecording && !service.isPaused) {
          for (int i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] =
                0.1 +
                (0.9 *
                    (0.5 +
                        0.5 *
                            (i % 2 == 0 ? 1 : -1) *
                            (0.5 +
                                0.5 *
                                    sin(_waveController.value * 2 * 3.14159))));
          }
        } else {
          // Mantener ondas estáticas cuando está pausado
          _waveHeights = List.generate(8, (_) => 0.1);
        }

        return GestureDetector(
          onTap: () async {
            print('🔔 Widget flotante tocado');
            
            if (service._paciente != null && service._tipoGrabacion != null) {
              print('� Navegando de vuelta a la pantalla de grabación');
              
              // Ocultar el overlay primero
              service.hideOverlay();
              
              // Marcar que estamos en la pantalla de audio
              service.setInAudioScreen(true);
              
              // Navegar a la pantalla de grabación
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => AudioRecorderScreen(
                    paciente: service._paciente!,
                    tipoGrabacion: service._tipoGrabacion!,
                  ),
                ),
              );
              
              print('↩️ Volvió de la pantalla de grabación');
            } else {
              print('❌ No hay datos guardados para navegar');
            }
          },
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color:
                  service.isPaused
                      ? Colors.orange
                      : Colors.cyan,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ondas de audio a la izquierda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _waveHeights.length,
                      (index) => Container(
                        width: 3,
                        height: 20 * _waveHeights[index],
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Icono de estado de grabación
                  Icon(
                    service.isPaused
                        ? Icons.pause
                        : Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 16,
                  ),

                  // Sección derecha: Duración y botón
                  Row(
                    children: [
                      // Duración a la izquierda del botón
                      Text(
                        service.formatTime(service.seconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón de pausar/reanudar
                      GestureDetector(
                        onTap: () async {
                          if (service.isPaused) {
                            await service.resumeRecording();
                          } else {
                            await service.pauseRecording();
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                service.isPaused
                                    ? Colors.orange
                                    : const Color.fromARGB(255, 87, 226, 224),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            service.isPaused ? Icons.mic : Icons.pause,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ),
          ),
        );
      },
    );
  }
}
