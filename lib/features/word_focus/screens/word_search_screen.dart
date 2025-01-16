import 'package:flutter/material.dart';
import '../models/word_search_game.dart';
import '../widgets/word_search_widget.dart';

class WordSearchScreen extends StatelessWidget {
  const WordSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelime Bulma Oyunu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nasıl Oynanır?'),
                  content: const Text(
                    '1. Harflere tıklayarak kelime oluşturun\n'
                    '2. Harfler yan yana veya alt alta olmalıdır\n'
                    '3. Doğru kelimeyi bulduğunuzda puan kazanırsınız\n'
                    '4. Süre dolmadan tüm kelimeleri bulmaya çalışın!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: WordSearchWidget(
              game: WordSearchGame.easy(), // Başlangıç için kolay seviye
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordSearchScreen(),
                      ),
                    );
                  },
                  child: const Text('Yeni Oyun'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Çıkış'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
