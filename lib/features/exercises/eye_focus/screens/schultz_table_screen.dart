import 'dart:math';
import 'package:flutter/material.dart';

class SchultzTableScreen extends StatefulWidget {
  const SchultzTableScreen({Key? key}) : super(key: key);

  @override
  State<SchultzTableScreen> createState() => _SchultzTableScreenState();
}

class _SchultzTableScreenState extends State<SchultzTableScreen> {
  late List<int> numbers;
  int currentNumber = 1;
  final int gridSize = 6;
  bool isExerciseStarted = false;
  List<bool> foundNumbers = [];
  int score = 0;
  int wrongAttempts = 0;
  Stopwatch stopwatch = Stopwatch();
  bool showHelp = false;

  @override
  void initState() {
    super.initState();
    _initializeNumbers();
  }

  void _initializeNumbers() {
    numbers = List.generate(gridSize * gridSize, (index) => index + 1);
    numbers.shuffle(Random());
    foundNumbers = List.generate(gridSize * gridSize, (index) => false);
    score = 0;
    wrongAttempts = 0;
    stopwatch.reset();
  }

  void _onNumberTap(int number) {
    if (!isExerciseStarted) return;

    if (number == currentNumber) {
      setState(() {
        foundNumbers[numbers.indexOf(number)] = true;
        currentNumber++;
        // Doğru sayı için puan ekle (hızlı bulma bonusu dahil)
        int timeBonus = (5000 / stopwatch.elapsedMilliseconds).round();
        score += 100 + timeBonus - (wrongAttempts * 10);

        if (currentNumber > gridSize * gridSize) {
          stopwatch.stop();
          _showCompletionDialog();
        }
      });
    } else {
      setState(() {
        wrongAttempts++;
        score = score > 10 ? score - 10 : 0; // Yanlış tıklama için puan düşür
      });
      // Yanlış tıklama geri bildirimi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Yanlış sayı! $currentNumber\'den başlayarak devam edin.'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleHelp() {
    setState(() {
      showHelp = !showHelp;
    });
  }

  void _startExercise() {
    setState(() {
      isExerciseStarted = true;
      stopwatch.start();
    });
  }

  void _showCompletionDialog() {
    final duration = stopwatch.elapsed;
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'Skor: $score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Süre: $minutes:$seconds',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Yanlış Deneme: $wrongAttempts',
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentNumber = 1;
                _initializeNumbers();
                stopwatch.reset();
                stopwatch.start();
              });
            },
            child: const Text('Tekrar Başla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schultz Tablosu'),
        backgroundColor: const Color(0xFF1A2B3C),
        elevation: 0,
        actions: [
          if (isExerciseStarted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Skor: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _toggleHelp,
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2B3C),
              Color(0xFF2C3E50),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showHelp)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Nasıl Oynanır?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. 1\'den 36\'ya kadar sayıları sırayla bulun\n'
                        '2. Her doğru sayı için puan kazanın\n'
                        '3. Ne kadar hızlı bulursanız o kadar çok bonus puan\n'
                        '4. Yanlış tıklamalar puanınızı düşürür\n'
                        '5. Bulunan sayılar yeşil renkte gösterilir',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isExerciseStarted)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.grid_on,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Schultz Tablosu',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sayıları sırayla bularak\nkonsantrasyonunuzu geliştirin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _startExercise,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'BAŞLA',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridSize,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: numbers.length,
                            itemBuilder: (context, index) {
                              final number = numbers[index];
                              final isFound = foundNumbers[index];
                              final isNext = number == currentNumber;
                              return _buildNumberTile(number, isFound, isNext);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberTile(int number, bool isFound, bool isNext) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color:
              isFound ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
