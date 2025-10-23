import 'package:flutter/material.dart';

/// Widget para mostrar el placeholder cuando no hay marcas
class EmptyMarksPlaceholder extends StatelessWidget {
  const EmptyMarksPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Aún no hay marcas de audio',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
