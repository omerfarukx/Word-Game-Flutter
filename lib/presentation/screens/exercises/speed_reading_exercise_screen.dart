import 'package:flutter/material.dart';

class SpeedReadingExerciseScreen extends StatefulWidget {
  const SpeedReadingExerciseScreen({super.key});

  @override
  State<SpeedReadingExerciseScreen> createState() =>
      _SpeedReadingExerciseScreenState();
}

class _SpeedReadingExerciseScreenState
    extends State<SpeedReadingExerciseScreen> {
  final String text =
      'Uzaydaki cisimlerden yansıyarak veya doğrudan doğruya gelen, gözle görülen ışık, ışınlar, kızılötesi, röntgen ışınları, radyo dalgaları gibi her türlü elektromanyetik yayınlar kainat hakkında bilgi toplamak için çok lüzumlu delillerdir. Bu deliller ya klasik manada optik teleskoplarla veya çok daha modern radyo teleskoplarla incelenir.';

  int timeLeft = 24;
  bool isExerciseStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Okuma'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: timeLeft / 24,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Süre: $timeLeft',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isExerciseStarted = !isExerciseStarted;
                });
                // Zamanlayıcı mantığı buraya eklenecek
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                isExerciseStarted ? 'Durdur' : 'Başla',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'İlk Günden\nGelişme Kaydet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
