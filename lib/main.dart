import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioRecorderScreen(),
    );
  }
}

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioPath;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initRecorder();

    // Animación tipo palpito
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory recordingsDir;

    if (Platform.isAndroid) {
      // Carpeta externa accesible para Android
      Directory? externalDir = await getExternalStorageDirectory();
      recordingsDir = Directory('${externalDir!.path}/Recordings');
    } else {
      // iOS: sandbox de la app
      Directory appDocDir = await getApplicationDocumentsDirectory();
      recordingsDir = Directory('${appDocDir.path}/Recordings');
    }

    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    String path =
        '${recordingsDir.path}/grabacion_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: path);
    print('Grabando en: $path');

    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_audioPath != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Audio guardado en: $_audioPath')));
    }
  }

  void _onMicPressed() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  void _shareRecording() {
    if (_audioPath != null) {
      Share.shareXFiles([XFile(_audioPath!)], text: 'Mi grabación');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale:
                  _isRecording ? _animation : const AlwaysStoppedAnimation(1.0),
              child: GestureDetector(
                onTap: _onMicPressed,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isRecording
                            ? const Color(0xFFFFCB60)
                            : const Color(0xFF3CD4FA),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? const Color(0xFFFFCB60)
                                : const Color(0xFF3CD4FA))
                            .withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!Platform.isAndroid)
              ElevatedButton.icon(
                onPressed: _audioPath != null ? _shareRecording : null,
                icon: const Icon(Icons.share),
                label: const Text('Exportar / Compartir'),
              ),
          ],
        ),
      ),
    );
  }
}
