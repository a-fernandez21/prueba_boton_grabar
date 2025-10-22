import 'package:flutter/material.dart';
import '../../models/paciente.dart';

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
