import 'package:flutter/material.dart';

/// Botón central de grabar/pausar
class CentralButton extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onPressed;

  const CentralButton({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color:
            isRecording && !isPaused
                ? const Color.fromARGB(255, 228, 228, 228)
                : const Color(0xFF00BBDA),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          (!isRecording || isPaused) ? Icons.mic : Icons.pause,
          color: (!isRecording || isPaused) ? Colors.white : Colors.black,
          size: 60,
        ),
      ),
    );
  }
}
