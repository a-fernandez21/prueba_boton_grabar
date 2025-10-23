import 'package:flutter/material.dart';

/// Botón de acción izquierdo (agregar marca o descartar)
class LeftActionButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback? onAddMark;
  final VoidCallback? onDiscard;

  const LeftActionButton({
    super.key,
    required this.isPaused,
    this.onAddMark,
    this.onDiscard,
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
        onPressed: isPaused ? onDiscard : onAddMark,
        icon: Icon(
          isPaused ? Icons.close : Icons.bookmark_add,
          color: isPaused ? Colors.red : Colors.blue,
          size: 42,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
