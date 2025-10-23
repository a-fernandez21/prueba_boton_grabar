import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Widget personalizado para el botón de grabación
class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final Animation<double> animation;
  final Future<void> Function() onPressed;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: isRecording ? animation : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: () {
          print('👆 GestureDetector activado');
          onPressed();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: AppConstants.recordButtonSize,
          height: AppConstants.recordButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isRecording
                    ? AppConstants.secondaryColor
                    : AppConstants.primaryColor,
            boxShadow: [
              BoxShadow(
                color: (isRecording
                        ? AppConstants.secondaryColor
                        : AppConstants.primaryColor)
                    .withOpacity(0.6),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isRecording ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: AppConstants.recordIconSize,
          ),
        ),
      ),
    );
  }
}
