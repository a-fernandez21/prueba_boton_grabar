import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/paciente.dart';

/// Widget para seleccionar un paciente de una lista
class PatientSelector extends StatelessWidget {
  final Paciente? selectedPatient;
  final List<Paciente> patients;
  final ValueChanged<Paciente?> onChanged;

  const PatientSelector({
    super.key,
    required this.selectedPatient,
    required this.patients,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccione un paciente',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Paciente>(
          value: selectedPatient,
          dropdownColor: Colors.white,
          items:
              patients.map((paciente) {
                return DropdownMenuItem<Paciente>(
                  value: paciente,
                  child: Text(paciente.displayText),
                );
              }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.lightBlueAccent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.lightBlueAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.lightBlueAccent,
                width: 2,
              ),
            ),
            hintText: 'Seleccionar paciente...',
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

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
        _RecordingTypeButton(
          label: 'Nueva anamnesis',
          isSelected: selectedType == 'Nueva anamnesis',
          enabled: enabled,
          onPressed: () => onTypeSelected('Nueva anamnesis'),
        ),
        const SizedBox(height: 12),
        _RecordingTypeButton(
          label: 'Nuevo seguimiento',
          isSelected: selectedType == 'Nuevo seguimiento',
          enabled: enabled,
          onPressed: () => onTypeSelected('Nuevo seguimiento'),
        ),
      ],
    );
  }
}

/// Botón individual de tipo de grabación
class _RecordingTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onPressed;

  const _RecordingTypeButton({
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
