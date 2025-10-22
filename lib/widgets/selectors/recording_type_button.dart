import 'package:flutter/material.dart';

/// Botón individual de tipo de grabación
class RecordingTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onPressed;

  const RecordingTypeButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor:
            isSelected ? Colors.lightBlueAccent.withOpacity(0.1) : Colors.white,
        side: BorderSide(
          color:
              enabled
                  ? (isSelected
                      ? Colors.lightBlueAccent
                      : Colors.lightBlueAccent.withOpacity(0.5))
                  : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isSelected) ...[
            const Icon(
              Icons.check_circle,
              color: Colors.lightBlueAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.lightBlueAccent : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
