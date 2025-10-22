import 'package:flutter/material.dart';
import '../../models/paciente.dart';

/// Widget para la ficha del paciente
class PatientInfoCard extends StatelessWidget {
  final Paciente paciente;

  const PatientInfoCard({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ficha del paciente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 228, 228, 228),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Paciente', paciente.nombreCompleto),
              const SizedBox(height: 8),
              _buildInfoRow('Edad', '${paciente.edad}'),
              const SizedBox(height: 8),
              _buildInfoRow('Enfermedades declaradas', 'Ninguna'),
              const SizedBox(height: 8),
              _buildInfoRow('Última visita', '03/10/2025'),
              const SizedBox(height: 8),
              _buildInfoRow('Próxima visita', 'Sin fecha'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: const TextStyle(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
