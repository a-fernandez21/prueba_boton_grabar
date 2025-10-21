import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

/// Servicio para gestionar grabaciones de audio (Singleton)
class AudioRecorderService {
  // Singleton
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();
  
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentRecordingPath;
  
  FlutterSoundRecorder get recorder => _recorder;
  String? get currentRecordingPath => _currentRecordingPath;
  bool get isInitialized => _isInitialized;

  /// Inicializa el grabador y solicita permisos
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Solicitar permisos
      final micStatus = await Permission.microphone.request();
      final storageStatus = await Permission.storage.request();
      
      if (!micStatus.isGranted) {
        print('✗ Permiso de micrófono denegado');
        return false;
      }
      
      if (!storageStatus.isGranted) {
        print('⚠️ Permiso de almacenamiento denegado');
      }
      
      // Abrir sesión de grabación con stream de progreso habilitado
      await _recorder.openRecorder();
      
      // Configurar la frecuencia del stream de progreso (cada 100ms)
      await _recorder.setSubscriptionDuration(const Duration(milliseconds: 100));
      
      _isInitialized = true;
      print('✓ Grabador inicializado correctamente con stream de progreso');
      return true;
    } on Exception catch (e) {
      print('✗ Error al inicializar grabador: $e');
      return false;
    }
  }

  /// Inicia la grabación
  Future<String?> startRecording() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        print('⚠️ No se pudo inicializar el grabador');
        return null;
      }
    }
    
    try {
      final path = await _getRecordingPath();
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        // Habilitar el stream de progreso para obtener decibelios
        // Se emitirá un evento cada ~100ms aproximadamente
      );
      _currentRecordingPath = path;
      
      print('✓ Grabación iniciada: $path');
      return path;
    } on Exception catch (e) {
      print('✗ Error al iniciar grabación: $e');
      return null;
    }
  }

  /// Pausa la grabación
  Future<void> pauseRecording() async {
    try {
      await _recorder.pauseRecorder();
      print('⏸️ Grabación pausada');
    } on Exception catch (e) {
      print('✗ Error al pausar grabación: $e');
    }
  }

  /// Reanuda la grabación
  Future<void> resumeRecording() async {
    try {
      await _recorder.resumeRecorder();
      print('▶️ Grabación reanudada');
    } on Exception catch (e) {
      print('✗ Error al reanudar grabación: $e');
    }
  }

  /// Detiene la grabación
  Future<RecordingResult> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      
      if (_currentRecordingPath == null) {
        print('⚠️ No hay grabación activa');
        return RecordingResult(
          success: false, 
          message: 'No hay grabación activa',
        );
      }
      
      // Verificar que el archivo existe
      final audioFile = File(_currentRecordingPath!);
      final exists = await audioFile.exists();
      final fileSize = exists ? await audioFile.length() : 0;
      
      print('===================================');
      print(exists ? '✓ Grabación detenida' : '✗ Error al crear archivo');
      print('Archivo existe: $exists');
      print('Tamaño del archivo: $fileSize bytes');
      print('Ruta completa: $_currentRecordingPath');
      print('===================================');
      
      return RecordingResult(
        success: exists,
        path: _currentRecordingPath,
        fileSize: fileSize,
        message: exists 
            ? 'Audio guardado: $fileSize bytes\n$_currentRecordingPath'
            : 'Error: El archivo no se creó correctamente',
      );
    } on Exception catch (e) {
      print('✗ Error al detener grabación: $e');
      return RecordingResult(
        success: false, 
        message: 'Error al detener la grabación: $e',
      );
    }
  }

  /// Obtiene la lista de grabaciones
  Future<List<FileInfo>> getRecordings() async {
    try {
      final recordingsDir = await _getRecordingsDirectory();
      
      if (!await recordingsDir.exists()) {
        print('ℹ️ Carpeta de grabaciones no existe aún');
        return [];
      }
      
      final files = recordingsDir.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith(AppConstants.audioFileExtension))
          .toList();
      
      final fileInfoList = <FileInfo>[];
      for (final file in files) {
        final size = await file.length();
        final name = file.path.split('/').last;
        fileInfoList.add(FileInfo(path: file.path, name: name, size: size));
      }
      
      // Ordenar por fecha (más reciente primero)
      fileInfoList.sort((a, b) => b.path.compareTo(a.path));
      
      print('===================================');
      print('📁 Carpeta: ${recordingsDir.path}');
      print('📊 Total de archivos: ${fileInfoList.length}');
      for (final file in fileInfoList) {
        print('  • ${file.name} (${file.size} bytes)');
      }
      print('===================================');
      
      return fileInfoList;
    } on Exception catch (e) {
      print('✗ Error al listar grabaciones: $e');
      return [];
    }
  }

  /// Obtiene el directorio de grabaciones
  Future<Directory> _getRecordingsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('${AppConstants.androidDownloadPath}/${AppConstants.recordingsFolder}');
    } else {
      final appDocDir = await getApplicationDocumentsDirectory();
      return Directory('${appDocDir.path}/${AppConstants.recordingsFolder}');
    }
  }

  /// Genera la ruta para una nueva grabación
  Future<String> _getRecordingPath() async {
    final recordingsDir = await _getRecordingsDirectory();
    
    // Crear directorio si no existe
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = '${AppConstants.audioFilePrefix}$timestamp${AppConstants.audioFileExtension}';
    return '${recordingsDir.path}/$filename';
  }

  /// Libera recursos
  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}

/// Resultado de una operación de grabación
class RecordingResult {
  final bool success;
  final String? path;
  final int? fileSize;
  final String message;
  
  RecordingResult({
    required this.success,
    this.path,
    this.fileSize,
    required this.message,
  });
}

/// Información de un archivo de audio
class FileInfo {
  final String path;
  final String name;
  final int size;
  
  FileInfo({
    required this.path,
    required this.name,
    required this.size,
  });
}
