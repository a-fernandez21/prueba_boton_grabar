import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

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
