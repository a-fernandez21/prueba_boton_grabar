import 'package:flutter/material.dart';

/// Widget para el botón de minimizar
class MinimizeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MinimizeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Minimizar', style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Icon(Icons.logout, size: 16),
        ],
      ),
    );
  }
}
