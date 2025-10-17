import 'package:flutter/material.dart';

/// Constantes de la aplicación
class AppConstants {
  // Colores
  static const Color primaryColor = Color.fromARGB(255, 0, 187, 218);
  static const Color secondaryColor = Color.fromARGB(255, 255, 189, 86);
  static const Color textColor = Color.fromARGB(179, 120, 120, 120);
  
  // Tamaños
  static const double recordButtonSize = 170.0;
  static const double recordIconSize = 70.0;
  static const double appBarHeight = 40.0;
  
  // Duración de animaciones
  static const Duration animationDuration = Duration(seconds: 1);
  static const Duration snackBarDuration = Duration(seconds: 5);
  static const Duration snackBarShortDuration = Duration(seconds: 3);
  
  // Rutas de archivo
  static const String recordingsFolder = 'Recordings';
  static const String androidDownloadPath = '/storage/emulated/0/Download';
  static const String audioFilePrefix = 'grabacion_';
  static const String audioFileExtension = '.aac';
  
  // MethodChannel
  static const String methodChannelName = 'com.example.prueba_boton_grabar/file_manager';
  static const String openFileManagerMethod = 'openFileManager';
  
  // Textos
  static const String appTitle = 'Grabacion de consulta';
  static const String recordingInstruction = 'Pulsa el botón para empezar a grabar la consulta';
  static const String viewRecordingsLabel = 'Ver grabaciones';
  static const String exportShareLabel = 'Exportar / Compartir';
  static const String shareText = 'Mi grabación';
}
