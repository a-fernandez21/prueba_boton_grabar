import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/paciente.dart';
import '../services/audio_recorder_service.dart';

class AudioRecorderScreen extends StatefulWidget {
  final Paciente paciente;
  final String tipoGrabacion;

  const AudioRecorderScreen({
    super.key,
    required this.paciente,
    required this.tipoGrabacion,
  });

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  bool _isRecording = false;
  bool _isPaused = false;
  final AudioRecorderService _audioService = AudioRecorderService();

  // Cronómetro
  int _seconds = 0;
  Timer? _timer;

  // Visualizador de ondas basado en amplitud real
  StreamSubscription? _recorderSubscription;
  List<double> _waveHeights = List.generate(70, (_) => 0.1);
  double _currentAmplitude = 0.0;

  // Marcas en el audio
  List<String> _audioMarks = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
    // No iniciar grabación automáticamente
    // _startRecordingAutomatically();
  }

  Future<void> _initRecorder() async {
    await _audioService.initialize();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startWaveAnimation() {
    // Suscribirse al stream de amplitud del grabador
    _recorderSubscription = _audioService.recorder.onProgress?.listen((e) {
      if (!_isPaused && mounted) {
        // flutter_sound reporta valores POSITIVOS en el rango 0-120 dB
        // donde valores bajos = silencio y valores altos = sonido fuerte
        final decibels = e.decibels ?? 0.0;

        // Normalizar a un rango de 0.05 a 1.0 usando la escala positiva
        // 0-45 dB = silencio/ruido ambiente → 0.05 (ondas casi invisibles)
        // 65+ dB = voz muy fuerte → 1.0 (ondas al máximo)
        double normalizedAmplitude;

        if (decibels <= 45) {
          // Silencio o ruido ambiente bajo
          normalizedAmplitude = 0.05;
        } else if (decibels >= 65) {
          // Voz fuerte
          normalizedAmplitude = 1.0;
        } else {
          // Interpolación lineal entre 45 y 65 dB (rango de 20 dB)
          normalizedAmplitude = 0.05 + ((decibels - 45) / 20) * 0.95;
        }

        // Debug detallado
        print(
          '🎤 dB: $decibels → Amplitud: ${normalizedAmplitude.toStringAsFixed(2)} → Altura: ${(60 * normalizedAmplitude).toStringAsFixed(1)}px',
        );

        setState(() {
          _currentAmplitude = normalizedAmplitude;
          // Rotar las ondas y agregar la nueva amplitud
          _waveHeights.removeAt(0);
          _waveHeights.add(normalizedAmplitude);
        });
      }
    });
  }

  void _stopWaveAnimation() {
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    setState(() {
      // Resetear ondas a silencio
      _waveHeights = List.generate(50, (_) => 0.1);
      _currentAmplitude = 0.0;
    });
  }

  void _pauseWaveAnimation() {
    // Cancelar suscripción cuando está pausado, pero mantener las ondas visibles
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    // NO resetear _waveHeights ni _currentAmplitude para mantener el estado visual
  }

  String _formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() {
        _isRecording = true;
        _isPaused = false;
      });
      _startTimer();
      _startWaveAnimation();
    }
  }

  Future<void> _pauseRecording() async {
    if (!_isRecording) return; // No pausar si no está grabando
    await _audioService.pauseRecording();
    setState(() {
      _isPaused = true;
    });
    _pauseWaveAnimation();
  }

  Future<void> _resumeRecording() async {
    await _audioService.resumeRecording();
    setState(() {
      _isPaused = false;
    });
    _startWaveAnimation();
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return; // No detener si no está grabando

    _stopTimer();
    _stopWaveAnimation();
    final result = await _audioService.stopRecording();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _seconds = 0;
      _audioMarks.clear(); // Limpiar marcas al guardar
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          duration: AppConstants.snackBarDuration,
        ),
      );

      // Volver a la pantalla anterior después de detener
      Navigator.pop(context);
    }
  }

  void _addMark() {
    // Añadir marca en el tiempo actual
    final String timeStamp = _formatTime(_seconds);
    setState(() {
      _audioMarks.add(timeStamp);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marca añadida en $timeStamp'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _removeMark(int index) {
    setState(() {
      _audioMarks.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marca eliminada'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _discardRecording() async {
    // Detener la grabación sin guardar
    _stopTimer();
    _stopWaveAnimation();
    await _audioService.stopRecording();

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _seconds = 0;
      _audioMarks.clear(); // Limpiar marcas
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grabación descartada'),
          duration: Duration(seconds: 2),
        ),
      );

      // Volver a la pantalla anterior
      Navigator.pop(context);
    }
  }

  void _minimizeRecording() {
    // Volver a la pantalla anterior sin detener la grabación
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _stopTimer();
    _stopWaveAnimation();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sección superior (gris inicial/pausado, cyan cuando graba)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 16,
            ),
            color: _isRecording && !_isPaused ? Colors.cyan : Colors.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón minimizar en la esquina superior derecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _minimizeRecording,
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
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text(
                        'Volver',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Estado: Grabando/Pausado centrado
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: (!_isRecording || _isPaused) ? Colors.orange : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (!_isRecording || _isPaused) ? 'Pausado' : 'Grabando',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cronómetro centrado
                Center(
                  child: Text(
                    _formatTime(_seconds),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Visualizador de ondas de audio
                Stack(
                  children: [
                    Container(
                      height: 60,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(
                          _waveHeights.length,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              height: 70 * _waveHeights[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Marcadores de audio
                    
                  ],
                ),

                const SizedBox(height: 8),

                // Tipo de grabación
                Text(
                  widget.tipoGrabacion,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          const SizedBox(height: 24),

          // Botones de control
          Stack(
            alignment: Alignment.center,
            children: [
              // Row para mantener el layout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Espacio para botón izquierdo
                  SizedBox(width: _isRecording ? 48 : 0),
                  SizedBox(width: _isRecording ? 24 : 0),
                  // Botón central siempre visible
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:
                          _isRecording && !_isPaused
                              ? Color.fromARGB(255, 228, 228, 228)
                              : const Color(0xFF00BBDA),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (!_isRecording) {
                          _startRecording();
                        } else if (_isPaused) {
                          _resumeRecording();
                        } else {
                          _pauseRecording();
                        }
                      },
                      icon: Icon(
                        (!_isRecording || _isPaused) ? Icons.mic : Icons.pause,
                        color:
                            (!_isRecording || _isPaused)
                                ? Colors.white
                                : Colors.black,
                        size: 60,
                      ),
                    ),
                  ),
                  SizedBox(width: _isRecording ? 24 : 0),
                  SizedBox(width: _isRecording ? 48 : 0),
                ],
              ),

              // Botón Descartar - Animado desde el centro hacia la izquierda
              AnimatedPositioned(
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutBack,
                left:
                    _isRecording
                        ? MediaQuery.of(context).size.width / 2 - 132
                        : MediaQuery.of(context).size.width / 2 - 40,
                child: AnimatedScale(
                  scale: _isRecording ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _isRecording ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 228, 228, 228),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed:
                            _isRecording
                                ? (_isPaused ? _discardRecording : _addMark)
                                : null,
                        icon: Icon(
                          _isPaused ? Icons.close : Icons.bookmark_add,
                          color: _isPaused ? Colors.red : Colors.blue,
                          size: 42,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),

              // Botón Detener - Animado desde el centro hacia la derecha
              AnimatedPositioned(
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeOutBack,
                right:
                    _isRecording
                        ? MediaQuery.of(context).size.width / 2 - 132
                        : MediaQuery.of(context).size.width / 2 - 40,
                child: AnimatedScale(
                  scale: _isRecording ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: _isRecording ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 228, 228, 228),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _isPaused ? _stopRecording : null,
                        icon: Icon(
                          Icons.check,
                          color: _isPaused ? Colors.green : Colors.grey,
                          size: 42,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Área scrollable con ficha del paciente y marcas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
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
                      color: Color.fromARGB(255, 228, 228, 228),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Paciente: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: widget.paciente.nombreCompleto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
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
                                text: '${widget.paciente.edad}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
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
                  ),

                  // Lista de marcas de audio
                  const SizedBox(height: 16),
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
                        _audioMarks.isEmpty
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
                                for (int i = 0; i < _audioMarks.length; i += 2)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          i + 2 < _audioMarks.length ? 8 : 0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.bookmark,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 2),
                                                    Expanded(
                                                      child: Text(
                                                        _audioMarks[i],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed:
                                                          () => _removeMark(i),
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                        color: Colors.red,
                                                        size: 26,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (i + 1 < _audioMarks.length) ...[
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.bookmark,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Expanded(
                                                        child: Text(
                                                          _audioMarks[i + 1],

                                                          style:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed:
                                                            () => _removeMark(
                                                              i + 1,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color: Colors.red,
                                                          size: 25,
                                                        ),
                                                        constraints:
                                                            const BoxConstraints(),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
              ),
            ),
          ),

          // Botón historia clínica
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navegar a la historia clínica
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Función de historia clínica en desarrollo',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Ver historia clínica',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
