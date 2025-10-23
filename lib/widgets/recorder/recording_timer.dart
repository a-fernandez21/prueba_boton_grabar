import 'package:flutter/material.dart';

/// Widget para el cronómetro de grabación
class RecordingTimer extends StatelessWidget {
  final int seconds;

  const RecordingTimer({super.key, required this.seconds});

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(seconds),
      style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
