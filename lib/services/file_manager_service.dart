import 'dart:io';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Servicio para gestionar la apertura del gestor de archivos nativo
class FileManagerService {
  static const platform = MethodChannel(AppConstants.methodChannelName);

  /// Abre el gestor de archivos del sistema en la carpeta de grabaciones
  Future<bool> openFileManager() async {
    if (!Platform.isAndroid) {
      // En iOS no tenemos implementación nativa del gestor de archivos
      print('ℹ️ Gestor de archivos no disponible en iOS');
      return false;
    }
    
    try {
      final recordingsPath = '${AppConstants.androidDownloadPath}/${AppConstants.recordingsFolder}';
      final result = await platform.invokeMethod(
        AppConstants.openFileManagerMethod,
        {'path': recordingsPath},
      );
      
      if (result == true) {
        print('✓ Gestor de archivos abierto exitosamente');
        return true;
      }
      print('⚠️ No se pudo abrir el gestor de archivos');
      return false;
    } on PlatformException catch (e) {
      print('✗ Error de plataforma al abrir gestor de archivos: ${e.message}');
      return false;
    } on Exception catch (e) {
      print('✗ Error al abrir gestor de archivos: $e');
      return false;
    }
  }
}
