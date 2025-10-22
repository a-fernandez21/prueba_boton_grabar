import 'package:flutter/material.dart';

/// Widget para el indicador de estado de grabación (Grabando/Pausado)
class RecordingStatusIndicator extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;

  const RecordingStatusIndicator({
    super.key,
    required this.isRecording,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPaused ? Icons.pause : Icons.fiber_manual_record,
          color: (!isRecording || isPaused) ? Colors.orange : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          (!isRecording || isPaused) ? 'Pausado' : 'Grabando',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}
