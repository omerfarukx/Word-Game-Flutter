import 'package:flutter/material.dart';

class TargetWordsDisplay extends StatelessWidget {
  final List<String> targetWords;
  final List<String> foundWords;

  const TargetWordsDisplay({
    super.key,
    required this.targetWords,
    required this.foundWords,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Bulunacak Kelimeler:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: targetWords.map((word) {
              final isFound = foundWords.contains(word);
              return Chip(
                label: Text(
                  word,
                  style: TextStyle(
                    color: isFound ? Colors.white : Colors.black,
                    fontWeight: isFound ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                backgroundColor: isFound ? Colors.green[400] : Colors.teal[100],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
