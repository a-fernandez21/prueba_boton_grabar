import 'package:flutter/material.dart';
import 'empty_marks_placeholder.dart';
import 'audio_marks_grid.dart';

/// Widget para la lista de marcas de audio
class AudioMarksList extends StatelessWidget {
  final List<String> audioMarks;
  final Function(int) onRemoveMark;

  const AudioMarksList({
    super.key,
    required this.audioMarks,
    required this.onRemoveMark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marcas de audio',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 228, 228, 228),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              audioMarks.isEmpty
                  ? const EmptyMarksPlaceholder()
                  : AudioMarksGrid(
                    audioMarks: audioMarks,
                    onRemoveMark: onRemoveMark,
                  ),
        ),
      ],
    );
  }
}
