import 'package:flutter/material.dart';
import 'central_button.dart';
import 'stop_button.dart';
import 'left_action_button.dart';

/// Widget para los botones de control de grabación
class RecordingControlButtons extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onRecordOrPause;
  final VoidCallback onStop;
  final VoidCallback? onAddMark;
  final VoidCallback? onDiscard;

  const RecordingControlButtons({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onRecordOrPause,
    required this.onStop,
    this.onAddMark,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Row para mantener el layout
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: isRecording ? 48 : 0),
            SizedBox(width: isRecording ? 24 : 0),
            // Botón central siempre visible
            CentralButton(
              isRecording: isRecording,
              isPaused: isPaused,
              onPressed: onRecordOrPause,
            ),
            SizedBox(width: isRecording ? 24 : 0),
            SizedBox(width: isRecording ? 48 : 0),
          ],
        ),

        // Botón izquierdo - Agregar marca o descartar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          left:
              isRecording
                  ? MediaQuery.of(context).size.width / 2 - 132
                  : MediaQuery.of(context).size.width / 2 - 40,
          child: AnimatedScale(
            scale: isRecording ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: isRecording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              child: LeftActionButton(
                isPaused: isPaused,
                onAddMark: onAddMark,
                onDiscard: onDiscard,
              ),
            ),
          ),
        ),

        // Botón Detener - Animado desde el centro hacia la derecha
        AnimatedPositioned(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          right:
              isRecording
                  ? MediaQuery.of(context).size.width / 2 - 132
                  : MediaQuery.of(context).size.width / 2 - 40,
          child: AnimatedScale(
            scale: isRecording ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: isRecording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              child: StopButton(isPaused: isPaused, onPressed: onStop),
            ),
          ),
        ),
      ],
    );
  }
}
