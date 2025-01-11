import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class SchultzTableScreen extends StatefulWidget {
  const SchultzTableScreen({Key? key}) : super(key: key);

  @override
  State<SchultzTableScreen> createState() => _SchultzTableScreenState();
}

class _SchultzTableScreenState extends State<SchultzTableScreen> {
  final int gridSize = 5;
  late List<int> numbers;
  int currentNumber = 1;
  int score = 0;
  bool isPlaying = false;
  final int maxNumber = 25;
  final stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _initializeNumbers();
  }

  void _initializeNumbers() {
    numbers = List.generate(maxNumber, (index) => index + 1);
    numbers.shuffle(Random());
  }

  void _handleNumberTap(int number) {
    if (!isPlaying) return;

    if (number == currentNumber) {
      setState(() {
        score += 10;
        currentNumber++;

        if (currentNumber > maxNumber) {
          _showCompletionDialog();
        }
      });
    }
  }

  void _startGame() {
    setState(() {
      _initializeNumbers();
      currentNumber = 1;
      score = 0;
      isPlaying = true;
      stopwatch.reset();
      stopwatch.start();
    });
  }

  void _showCompletionDialog() {
    stopwatch.stop();
    final duration = stopwatch.elapsed;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tebrikler!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Skorunuz: $score'),
            const SizedBox(height: 8),
            Text(
              'Süre: ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isPlaying = false;
              });
            },
            child: const Text('Tamam'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Schultz Tablosu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: ThemeConstants.darkSurfaceColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Sıradaki Sayı: $currentNumber',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Skor: $score',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: isPlaying
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: numbers.length,
                    itemBuilder: (context, index) {
                      final number = numbers[index];
                      final isFound = number < currentNumber;

                      return Card(
                        color: isFound
                            ? Colors.green.withOpacity(0.3)
                            : ThemeConstants.darkSurfaceColor,
                        child: InkWell(
                          onTap: () => _handleNumberTap(number),
                          child: Center(
                            child: Text(
                              number.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isFound ? Colors.green : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sayıları sırayla bulun',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1\'den 25\'e kadar olan sayıları\nsırasıyla bulup tıklayın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConstants.lightPrimaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Başla',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
