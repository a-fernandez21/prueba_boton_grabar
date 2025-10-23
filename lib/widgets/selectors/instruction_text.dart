import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Widget para el texto instructivo
class InstructionText extends StatelessWidget {
  const InstructionText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        AppConstants.recordingInstruction,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          color: AppConstants.textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
