import 'package:flutter/material.dart';
import '../models/paciente.dart';

/// Widget para el encabezado de estado de grabación (gris/cyan)
class RecordingHeader extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final int seconds;
  final List<double> waveHeights;
  final String tipoGrabacion;
  final VoidCallback onMinimize;

  const RecordingHeader({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.seconds,
    required this.waveHeights,
    required this.tipoGrabacion,
    required this.onMinimize,
  });

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      color: isRecording && !isPaused ? Colors.cyan : Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón minimizar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onMinimize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Minimizar', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.logout, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Estado: Grabando/Pausado
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPaused ? Icons.pause : Icons.fiber_manual_record,
                  color: (!isRecording || isPaused) ? Colors.orange : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  (!isRecording || isPaused) ? 'Pausado' : 'Grabando',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Cronómetro
          Center(
            child: Text(
              _formatTime(seconds),
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Visualizador de ondas
          WaveVisualizer(waveHeights: waveHeights),
          const SizedBox(height: 8),

          // Tipo de grabación
          Text(
            tipoGrabacion,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para el visualizador de ondas de audio
class WaveVisualizer extends StatelessWidget {
  final List<double> waveHeights;

  const WaveVisualizer({
    super.key,
    required this.waveHeights,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 60,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              waveHeights.length,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  height: 70 * waveHeights[index],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget para los botones de control de grabación
class RecordingControlButtons extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onRecordOrPause;
  final VoidCallback onStop;

  const RecordingControlButtons({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onRecordOrPause,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Row para mantener el layout
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: isRecording ? 48 : 0),
            SizedBox(width: isRecording ? 24 : 0),
            // Botón central siempre visible
            _CentralButton(
              isRecording: isRecording,
              isPaused: isPaused,
              onPressed: onRecordOrPause,
            ),
            SizedBox(width: isRecording ? 24 : 0),
            SizedBox(width: isRecording ? 48 : 0),
          ],
        ),

        // Botón Descartar - Animado desde el centro hacia la izquierda
        AnimatedPositioned(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          left:
              isRecording
                  ? MediaQuery.of(context).size.width / 2 - 132
                  : MediaQuery.of(context).size.width / 2 - 40,
          child: AnimatedScale(
            scale: isRecording ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              opacity: isRecording ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutBack,
              child: _StopButton(
                isPaused: isPaused,
                onPressed: onStop,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón central de grabar/pausar
class _CentralButton extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onPressed;

  const _CentralButton({
    required this.isRecording,
    required this.isPaused,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color:
            isRecording && !isPaused
                ? const Color.fromARGB(255, 228, 228, 228)
                : const Color(0xFF00BBDA),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          (!isRecording || isPaused) ? Icons.mic : Icons.pause,
          color:
              (!isRecording || isPaused)
                  ? Colors.white
                  : Colors.black,
          size: 60,
        ),
      ),
    );
  }
}

/// Botón de detener grabación
class _StopButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPressed;

  const _StopButton({
    required this.isPaused,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 228, 228),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isPaused ? onPressed : null,
        icon: Icon(
          Icons.check,
          color: isPaused ? Colors.green : Colors.grey,
          size: 42,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Widget para la ficha del paciente
class PatientInfoCard extends StatelessWidget {
  final Paciente paciente;

  const PatientInfoCard({
    super.key,
    required this.paciente,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 228, 228, 228),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ficha del paciente',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: 'Nombre: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: paciente.nombre,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'ID: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: paciente.id,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'Edad: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '${paciente.edad}',
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              text: 'Enfermedades declaradas: ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Ninguna',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              text: 'Última visita: ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '03/10/2025',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text.rich(
            TextSpan(
              text: 'Próxima visita: ',
              style: TextStyle(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Sin fecha',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para la lista de marcas de audio
class AudioMarksList extends StatelessWidget {
  final List<String> audioMarks;
  final Function(int) onRemoveMark;

  const AudioMarksList({
    super.key,
    required this.audioMarks,
    required this.onRemoveMark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marcas en el audio',
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
          child:
              audioMarks.isEmpty
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aún no hay marcas de audio',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                  : Column(
                    children: [
                      for (int i = 0; i < audioMarks.length; i += 2)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i + 2 < audioMarks.length ? 8 : 0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _AudioMarkItem(
                                  index: i,
                                  time: audioMarks[i],
                                  onRemove: () => onRemoveMark(i),
                                ),
                              ),
                              if (i + 1 < audioMarks.length) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _AudioMarkItem(
                                    index: i + 1,
                                    time: audioMarks[i + 1],
                                    onRemove: () => onRemoveMark(i + 1),
                                  ),
                                ),
                              ] else
                                const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                    ],
                  ),
        ),
      ],
    );
  }
}

/// Item individual de marca de audio
class _AudioMarkItem extends StatelessWidget {
  final int index;
  final String time;
  final VoidCallback onRemove;

  const _AudioMarkItem({
    required this.index,
    required this.time,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Marca ${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 25,
                ),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
