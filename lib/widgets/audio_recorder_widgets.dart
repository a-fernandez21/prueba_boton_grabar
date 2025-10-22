import 'package:flutter/material.dart';
import '../models/paciente.dart';

/// Widget para el indicador de estado de grabación (Grabando/Pausado)
class RecordingStatusIndicator extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;

  const RecordingStatusIndicator({
    super.key,
    required this.isRecording,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}

/// Widget para el cronómetro de grabación
class RecordingTimer extends StatelessWidget {
  final int seconds;

  const RecordingTimer({super.key, required this.seconds});

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(seconds),
      style: const TextStyle(
        fontSize: 32,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// Widget para el botón de minimizar
class MinimizeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const MinimizeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Minimizar', style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Icon(Icons.logout, size: 16),
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 16),
      color: isRecording && !isPaused ? Colors.cyan : Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botón minimizar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [MinimizeButton(onPressed: onMinimize)],
          ),
          const SizedBox(height: 8),

          // Estado: Grabando/Pausado
          Center(
            child: RecordingStatusIndicator(
              isRecording: isRecording,
              isPaused: isPaused,
            ),
          ),

          // Cronómetro
          Center(child: RecordingTimer(seconds: seconds)),
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

  const WaveVisualizer({super.key, required this.waveHeights});

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
  final VoidCallback? onAddMark;
  final VoidCallback? onDiscard;

  const RecordingControlButtons({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.onRecordOrPause,
    required this.onStop,
    this.onAddMark,
    this.onDiscard,
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

        // Botón izquierdo - Agregar marca o descartar
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
              child: _LeftActionButton(
                isPaused: isPaused,
                onAddMark: onAddMark,
                onDiscard: onDiscard,
              ),
            ),
          ),
        ),

        // Botón Detener - Animado desde el centro hacia la derecha
        AnimatedPositioned(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          right:
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
              child: _StopButton(isPaused: isPaused, onPressed: onStop),
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
          color: (!isRecording || isPaused) ? Colors.white : Colors.black,
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

  const _StopButton({required this.isPaused, required this.onPressed});

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

/// Botón de acción izquierdo (agregar marca o descartar)
class _LeftActionButton extends StatelessWidget {
  final bool isPaused;
  final VoidCallback? onAddMark;
  final VoidCallback? onDiscard;

  const _LeftActionButton({
    required this.isPaused,
    this.onAddMark,
    this.onDiscard,
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
        onPressed: isPaused ? onDiscard : onAddMark,
        icon: Icon(
          isPaused ? Icons.close : Icons.bookmark_add,
          color: isPaused ? Colors.red : Colors.blue,
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
          'Marcas de audio',
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
                  ? const _EmptyMarksPlaceholder()
                  : _AudioMarksGrid(
                    audioMarks: audioMarks,
                    onRemoveMark: onRemoveMark,
                  ),
        ),
      ],
    );
  }
}

/// Widget para mostrar el placeholder cuando no hay marcas
class _EmptyMarksPlaceholder extends StatelessWidget {
  const _EmptyMarksPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
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
    );
  }
}

/// Widget para mostrar la cuadrícula de marcas
class _AudioMarksGrid extends StatelessWidget {
  final List<String> audioMarks;
  final Function(int) onRemoveMark;

  const _AudioMarksGrid({required this.audioMarks, required this.onRemoveMark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < audioMarks.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < audioMarks.length ? 8 : 0),
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
        color: Colors.lightBlueAccent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark, color: Colors.blue, size: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Widget para botones de acción principales
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? textColor;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
