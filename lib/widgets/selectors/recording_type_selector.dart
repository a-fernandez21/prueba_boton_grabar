import 'package:flutter/material.dart';
import 'recording_type_button.dart';

/// Widget para seleccionar el tipo de grabación
class RecordingTypeSelector extends StatelessWidget {
  final String? selectedType;
  final bool enabled;
  final ValueChanged<String> onTypeSelected;

  const RecordingTypeSelector({
    super.key,
    required this.selectedType,
    required this.enabled,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione el tipo de grabación:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        RecordingTypeButton(
          label: 'Nueva anamnesis',
          isSelected: selectedType == 'Nueva anamnesis',
          enabled: enabled,
          onPressed: () => onTypeSelected('Nueva anamnesis'),
        ),
        const SizedBox(height: 12),
        RecordingTypeButton(
          label: 'Nuevo seguimiento',
          isSelected: selectedType == 'Nuevo seguimiento',
          enabled: enabled,
          onPressed: () => onTypeSelected('Nuevo seguimiento'),
        ),
      ],
    );
  }
}
