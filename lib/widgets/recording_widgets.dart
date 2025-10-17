import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Widget para mostrar un diálogo informativo sobre grabaciones
class RecordingsInfoDialog extends StatelessWidget {
  final int fileCount;
  final String recordingsPath;

  const RecordingsInfoDialog({
    super.key,
    required this.fileCount,
    required this.recordingsPath,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.folder_open, color: AppConstants.secondaryColor),
          SizedBox(width: 10),
          Text('Grabaciones'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📂 Ubicación:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          const Text('Descargas > Recordings'),
          const SizedBox(height: 15),
          const Text(
            '📊 Archivos encontrados:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text('$fileCount grabación(es)'),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '💡 Cómo acceder:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('1. Abre la app "Archivos"'),
                Text('2. Ve a "Descargas"'),
                Text('3. Busca la carpeta "Recordings"'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

/// Widget para mostrar diálogo de "sin grabaciones"
class NoRecordingsDialog extends StatelessWidget {
  const NoRecordingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.info_outline, color: AppConstants.secondaryColor),
          SizedBox(width: 10),
          Text('Sin grabaciones'),
        ],
      ),
      content: const Text(
        'No hay grabaciones guardadas aún.\n\n¡Graba tu primer audio usando el botón central!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

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
            color: isRecording
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
