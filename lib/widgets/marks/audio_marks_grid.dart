import 'package:flutter/material.dart';
import 'audio_mark_item.dart';

/// Widget para mostrar la cuadrícula de marcas
class AudioMarksGrid extends StatelessWidget {
  final List<String> audioMarks;
  final Function(int) onRemoveMark;

  const AudioMarksGrid({
    super.key,
    required this.audioMarks,
    required this.onRemoveMark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < audioMarks.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < audioMarks.length ? 8 : 0),
            child: Row(
              children: [
                Expanded(
                  child: AudioMarkItem(
                    index: i,
                    time: audioMarks[i],
                    onRemove: () => onRemoveMark(i),
                  ),
                ),
                if (i + 1 < audioMarks.length) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: AudioMarkItem(
                      index: i + 1,
                      time: audioMarks[i + 1],
                      onRemove: () => onRemoveMark(i + 1),
                    ),
                  ),
                ] else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}
