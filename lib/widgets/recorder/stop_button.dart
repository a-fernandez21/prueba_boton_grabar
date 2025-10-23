import 'package:flutter/material.dart';

/// Botón de detener grabación
class StopButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPressed;

  const StopButton({
    super.key,
    required this.isPaused,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 228, 228),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isPaused ? onPressed : null,
        icon: Icon(
          Icons.check,
          color: isPaused ? Colors.green : Colors.grey,
          size: 42,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
