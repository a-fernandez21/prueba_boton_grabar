import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_recorder_service.dart';

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

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;

  void setAudioService(AudioRecorderService audioService) {
    _audioService = audioService;
  }

  void setInAudioScreen(bool inAudioScreen, [BuildContext? context]) {
    _isInAudioScreen = inAudioScreen;
    if (inAudioScreen) {
      hideOverlay();
    } else if (_isRecording && context != null) {
      showOverlay(context);
    }
  }

  void showOverlay(BuildContext? context) {
    if (_overlayEntry != null || _isInAudioScreen || context == null) return;

    _overlayEntry = OverlayEntry(
      builder:
          (_) => Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _FloatingRecordingWidget(),
          ),
    );

    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isRecording = false;
    _isPaused = false;
  }

  void startRecording() {
    _isRecording = true;
    _isPaused = false;
    _overlayEntry?.markNeedsBuild();
  }

  void stopRecording() {
    _isRecording = false;
    _isPaused = false;
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
}

class _FloatingRecordingWidget extends StatefulWidget {
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
            // Toggle pause/resume al tocar el widget
            if (service.isPaused) {
              await service.resumeRecording();
            } else {
              await service.pauseRecording();
            }
          },
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: service.isPaused ? Colors.orange : Colors.red,
              borderRadius: BorderRadius.circular(12),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de estado
                  Icon(
                    service.isPaused ? Icons.pause : Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(height: 4),

                  // Ondas de audio
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
                  const SizedBox(height: 4),

                  // Texto de estado
                  Text(
                    service.isPaused ? 'Pausado' : 'Grabando',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
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
