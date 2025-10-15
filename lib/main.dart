import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const platform = MethodChannel('com.example.prueba_boton_grabar/file_manager');
  
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
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    Directory recordingsDir;

    if (Platform.isAndroid) {
      // Android: Guardar en la carpeta de Descargas (accesible desde el explorador de archivos)
      Directory? downloadsDir = Directory('/storage/emulated/0/Download/Recordings');
      recordingsDir = downloadsDir;
    } else {
      // iOS: sandbox de la app
      Directory appDocDir = await getApplicationDocumentsDirectory();
      recordingsDir = Directory('${appDocDir.path}/Recordings');
    }

    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    String fileName = 'grabacion_${DateTime.now().millisecondsSinceEpoch}.aac';
    String path = '${recordingsDir.path}/$fileName';

    await _recorder.startRecorder(toFile: path);
    print('===================================');
    print('Grabando en: $path');
    print('Carpeta: ${recordingsDir.path}');
    print('Archivo: $fileName');
    print('===================================');

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
      // Verificar que el archivo existe
      File audioFile = File(_audioPath!);
      bool exists = await audioFile.exists();
      int fileSize = exists ? await audioFile.length() : 0;
      
      print('===================================');
      print('Grabación detenida');
      print('Archivo existe: $exists');
      print('Tamaño del archivo: ${fileSize} bytes');
      print('Ruta completa: $_audioPath');
      print('===================================');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exists 
              ? 'Audio guardado: ${fileSize} bytes\n$_audioPath'
              : 'Error: El archivo no se creó',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
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

  Future<void> _listRecordings() async {
    Directory recordingsDir;
    
    if (Platform.isAndroid) {
      recordingsDir = Directory('/storage/emulated/0/Download/Recordings');
      
      if (await recordingsDir.exists()) {
        List<FileSystemEntity> files = recordingsDir.listSync();
        
        print('===================================');
        print('Carpeta: ${recordingsDir.path}');
        print('Total de archivos: ${files.length}');
        for (var file in files) {
          if (file is File) {
            int size = await file.length();
            print('- ${file.path.split('/').last} (${size} bytes)');
          }
        }
        print('===================================');
        
        // Intentar abrir el gestor de archivos usando el MethodChannel
        try {
          final bool result = await platform.invokeMethod('openFileManager', {
            'path': recordingsDir.path,
          });
          
          if (result) {
            print('Gestor de archivos abierto exitosamente');
          }
        } catch (e) {
          print('Error al abrir gestor de archivos: $e');
          // Si falla, mostrar diálogo con instrucciones
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.folder_open, color: Color.fromARGB(255, 255, 189, 86)),
                  SizedBox(width: 10),
                  Text('Grabaciones'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📂 Ubicación:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text('Descargas > Recordings'),
                  SizedBox(height: 15),
                  Text(
                    '📊 Archivos encontrados:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text('${files.length} grabación(es)'),
                  SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                  child: Text('Entendido', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: Color.fromARGB(255, 255, 189, 86)),
                SizedBox(width: 10),
                Text('Sin grabaciones'),
              ],
            ),
            content: Text(
              'No hay grabaciones guardadas aún.\n\n¡Graba tu primer audio usando el botón central!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // iOS
      Directory appDocDir = await getApplicationDocumentsDirectory();
      recordingsDir = Directory('${appDocDir.path}/Recordings');
      
      if (await recordingsDir.exists()) {
        List<FileSystemEntity> files = recordingsDir.listSync();
        print('===================================');
        print('Archivos en ${recordingsDir.path}:');
        print('Total de archivos: ${files.length}');
        for (var file in files) {
          if (file is File) {
            int size = await file.length();
            print('- ${file.path.split('/').last} (${size} bytes)');
          }
        }
        print('===================================');
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} archivos encontrados\nRevisa la consola para ver la lista'),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay grabaciones guardadas')),
        );
      }
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
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Color.fromARGB(255, 0, 187, 218),
        foregroundColor: Colors.white,
        title: Text('Grabacion de consulta',style: TextStyle(fontWeight: FontWeight.bold),),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
        ),
      ),
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
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isRecording
                            ? Color.fromARGB(255, 255, 189, 86)
                            : const Color.fromARGB(255, 0, 187, 218),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? Color.fromARGB(255, 255, 189, 86)
                                : const Color.fromARGB(255, 0, 187, 218))
                            .withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (!_isRecording)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pulsa el botón para empezar a grabar la consulta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(179, 120, 120, 120),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (!Platform.isAndroid)
              ElevatedButton.icon(
                onPressed: _audioPath != null ? _shareRecording : null,
                icon: const Icon(Icons.share),
                label: const Text('Exportar / Compartir'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _listRecordings,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.folder),
        label: const Text('Ver grabaciones',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
        backgroundColor: Color.fromARGB(255, 255, 189, 86),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
