package com.example.prueba_boton_grabar

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.prueba_boton_grabar/file_manager"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openFileManager") {
                val path = call.argument<String>("path")
                if (path != null) {
                    openFileManager(path, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Path is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openFileManager(path: String, result: MethodChannel.Result) {
        try {
            // Intentar abrir la carpeta de Descargas
            val intent = Intent(Intent.ACTION_VIEW)
            val uri = Uri.parse("content://com.android.externalstorage.documents/document/primary:Download")
            intent.setDataAndType(uri, "vnd.android.document/directory")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            
            try {
                startActivity(intent)
                result.success(true)
            } catch (e: Exception) {
                // Fallback: abrir la app Files con un intent genérico
                val fallbackIntent = Intent(Intent.ACTION_VIEW)
                fallbackIntent.setType("resource/folder")
                fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                
                try {
                    startActivity(fallbackIntent)
                    result.success(true)
                } catch (e2: Exception) {
                    // Último intento: abrir gestor de archivos genérico
                    val genericIntent = Intent(Intent.ACTION_GET_CONTENT)
                    genericIntent.type = "*/*"
                    genericIntent.addCategory(Intent.CATEGORY_OPENABLE)
                    
                    try {
                        startActivity(Intent.createChooser(genericIntent, "Seleccionar gestor de archivos"))
                        result.success(true)
                    } catch (e3: Exception) {
                        result.error("ACTIVITY_NOT_FOUND", "No se pudo abrir el gestor de archivos", e3.message)
                    }
                }
            }
        } catch (e: Exception) {
            result.error("ERROR", "Error al abrir el gestor de archivos", e.message)
        }
    }
}
