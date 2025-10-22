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
    // Evitar crear múltiples timers
    if (_timer != null) {
      print('⚠️ Timer del overlay ya activo, no crear uno nuevo');
      return;
    }

    print('⏱️ Iniciando timer del overlay');
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
      // Cuando volvemos a la pantalla de audio, detener el timer del overlay
      _stopOverlayTimer();
      hideOverlay();
      return;
    }

    if (!_isRecording || context == null) return;

    // Actualizar estado en una sola pasada
    _seconds = currentSeconds ?? _seconds;
    _paciente = paciente ?? _paciente;
    _tipoGrabacion = tipoGrabacion ?? _tipoGrabacion;
    if (audioMarks != null) {
      _audioMarks = List.from(audioMarks);
    }

    showOverlay(context);
    _startOverlayTimer();
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
    _audioMarks.clear();
    _paciente = null;
    _tipoGrabacion = null;
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

  void _updateWaveHeights(RecordingOverlayService service) {
    if (service.isRecording && !service.isPaused) {
      final animValue = _waveController.value * 2 * pi;
      final sinValue = sin(animValue);

      for (int i = 0; i < _waveHeights.length; i++) {
        _waveHeights[i] =
            0.1 +
            (0.9 *
                (0.5 + 0.5 * (i % 2 == 0 ? 1 : -1) * (0.5 + 0.5 * sinValue)));
      }
    } else {
      _waveHeights = List.filled(8, 0.1);
    }
  }

  Future<void> _navigateToRecordingScreen(
    BuildContext context,
    RecordingOverlayService service,
  ) async {
    if (service._paciente == null || service._tipoGrabacion == null) return;

    // Detener el timer del overlay antes de navegar
    service._stopOverlayTimer();

    // Ocultar el overlay y marcar que estamos en la pantalla de audio
    service.hideOverlay();
    service.setInAudioScreen(true);

    // Navegar reemplazando la pantalla placeholder
    await Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => AudioRecorderScreen(
              paciente: service._paciente!,
              tipoGrabacion: service._tipoGrabacion!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = RecordingOverlayService();

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        _updateWaveHeights(service);

        return Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    service.isPaused
                        ? [Colors.orange.shade400, Colors.orange.shade600]
                        : [Colors.cyan.shade400, Colors.cyan.shade600],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primera fila: Ondas + Estado + Tiempo
                Row(
                  children: [
                    // Ondas de audio
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _waveHeights.length,
                          (index) => Container(
                            width: 3,
                            height: 25 * _waveHeights[index],
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Icono de estado
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        service.isPaused
                            ? Icons.pause
                            : Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),

                    const Spacer(),

                    // Duración
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.formatTime(service.seconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Segunda fila: Botones de control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Volver a pantalla
                    _buildControlButton(
                      icon: Icons.open_in_full,
                      label: 'Abrir',
                      color: Colors.white.withOpacity(0.9),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      onTap: () => _navigateToRecordingScreen(context, service),
                    ),

                    // Botón Pausar/Reanudar
                    _buildControlButton(
                      icon: service.isPaused ? Icons.play_arrow : Icons.pause,
                      label: service.isPaused ? 'Reanudar' : 'Pausar',
                      color: Colors.white.withOpacity(0.9),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      onTap: () async {
                        if (service.isPaused) {
                          await service.resumeRecording();
                        } else {
                          await service.pauseRecording();
                        }
                      },
                    ),

                    // Botón Detener
                    _buildControlButton(
                      icon: Icons.stop,
                      label: 'Detener',
                      color: Colors.white.withOpacity(0.9),
                      backgroundColor: Colors.red.withOpacity(0.3),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Detener grabación'),
                              content: const Text(
                                '¿Deseas detener y guardar la grabación?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed:
                                      () =>
                                          Navigator.of(dialogContext).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                  child: const Text('Guardar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          await service.stopRecordingFromOverlay();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Grabación guardada'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
