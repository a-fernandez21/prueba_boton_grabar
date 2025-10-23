import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

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
