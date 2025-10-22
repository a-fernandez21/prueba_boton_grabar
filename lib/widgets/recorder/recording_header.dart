import 'package:flutter/material.dart';
import 'recording_status_indicator.dart';
import 'recording_timer.dart';
import 'minimize_button.dart';
import 'wave_visualizer.dart';

/// Widget para el encabezado de estado de grabación (gris/cyan)
class RecordingHeader extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final int seconds;
  final List<double> waveHeights;
  final String tipoGrabacion;
  final VoidCallback onMinimize;

  const RecordingHeader({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.seconds,
    required this.waveHeights,
    required this.tipoGrabacion,
    required this.onMinimize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 16),
      color: isRecording && !isPaused ? Colors.cyan : Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón minimizar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [MinimizeButton(onPressed: onMinimize)],
          ),
          const SizedBox(height: 8),

          // Estado: Grabando/Pausado
          Center(
            child: RecordingStatusIndicator(
              isRecording: isRecording,
              isPaused: isPaused,
            ),
          ),

          // Cronómetro
          Center(child: RecordingTimer(seconds: seconds)),
          const SizedBox(height: 16),

          // Visualizador de ondas
          WaveVisualizer(waveHeights: waveHeights),
          const SizedBox(height: 8),

          // Tipo de grabación
          Text(
            tipoGrabacion,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
