import 'package:flutter/material.dart';

/// Item individual de marca de audio
class AudioMarkItem extends StatelessWidget {
  final int index;
  final String time;
  final VoidCallback onRemove;

  const AudioMarkItem({
    super.key,
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
