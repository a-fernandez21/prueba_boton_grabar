import 'package:flutter/material.dart';

/// Pantalla placeholder que se muestra cuando se minimiza una grabación
/// Esta pantalla permanece visible mientras el widget flotante está activo
class RecordingPlaceholderScreen extends StatelessWidget {
  const RecordingPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabación en Progreso'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false, // No mostrar botón de back
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono animado de grabación
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Grabación Minimizada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'La grabación continúa en segundo plano.\nToca el widget flotante para volver.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Indicador visual del widget flotante
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.cyan, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.cyan),
                  const SizedBox(width: 10),
                  Flexible(
                    child: const Text(
                      'Busca el widget flotante en la parte superior',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
