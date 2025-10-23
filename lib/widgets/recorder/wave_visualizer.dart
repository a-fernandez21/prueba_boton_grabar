import 'package:flutter/material.dart';

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
