import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/speed_reading_provider.dart';
import '../../widgets/countdown_dialog.dart';

class SpeedReadingExerciseScreen extends StatefulWidget {
  const SpeedReadingExerciseScreen({super.key});

  @override
  State<SpeedReadingExerciseScreen> createState() =>
      _SpeedReadingExerciseScreenState();
}

class _SpeedReadingExerciseScreenState
    extends State<SpeedReadingExerciseScreen> {
  String text = '';
  bool isExerciseStarted = false;
  bool isGameStarted = false;
  Timer? timer;
  int wordsPerMinute = 200;
  int totalWords = 0;
  int currentWordIndex = 0;
  String currentWord = '';
  List<String> words = [];
  int _countDown = 3;

  @override
  void initState() {
    super.initState();
    _selectRandomText();
  }

  void _selectRandomText() {
    try {
      final provider =
          Provider.of<SpeedReadingProvider>(context, listen: false);
      if (!provider.isInitialized) {
        Future.delayed(const Duration(milliseconds: 100), _selectRandomText);
        return;
      }

      final selectedText = provider.getRandomTextWithWordLimit();
      if (selectedText.isEmpty) {
        debugPrint('Metin seçilemedi');
        return;
      }

      setState(() {
        text = selectedText;
        words = text.split(' ');
        totalWords = words.length;
        currentWordIndex = 0;
        currentWord = '';
      });
    } catch (e) {
      debugPrint('Metin seçme hatası: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı Okuma Egzersizi'),
        content: const Text(
          'Bu egzersiz, okuma hızınızı artırmanıza yardımcı olacaktır. Metni istediğiniz hızda okuyabilirsiniz. Hazır olduğunuzda başlayın.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              startExercise();
            },
            child: const Text('BAŞLA'),
          ),
        ],
      ),
    );
  }

  void startExercise() {
    if (words.isEmpty) return;
    CountdownDialog.show(
      context,
      onFinished: _startReading,
    );
  }

  void _startReading() {
    setState(() {
      isExerciseStarted = true;
      currentWordIndex = 0;
      currentWord = words[currentWordIndex];
    });

    final wordDelay = (60000 / wordsPerMinute).round();
    timer = Timer.periodic(Duration(milliseconds: wordDelay), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (currentWordIndex < words.length - 1) {
          currentWordIndex++;
          currentWord = words[currentWordIndex];
        } else {
          stopExercise();
          _selectRandomText();
        }
      });
    });
  }

  void stopExercise() {
    timer?.cancel();
    if (!mounted) return;
    setState(() {
      isExerciseStarted = false;
      currentWord = '';
    });
  }

  void updateSpeed(int newSpeed) {
    setState(() {
      wordsPerMinute = newSpeed;
      if (isExerciseStarted) {
        stopExercise();
        startExercise();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SpeedReadingProvider>(context);

    if (!provider.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!isGameStarted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Hızlı Okuma'),
          backgroundColor: ThemeConstants.lightPrimaryColor,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ThemeConstants.lightPrimaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.menu_book,
                  size: 100,
                  color: ThemeConstants.lightPrimaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hızlı Okuma Egzersizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Bu egzersiz, okuma hızınızı artırmanıza ve anlama kabiliyetinizi geliştirmenize yardımcı olacaktır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isGameStarted = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.lightPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'DEVAM',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hızlı Okuma'),
        backgroundColor: ThemeConstants.lightPrimaryColor,
        actions: [
          if (!isExerciseStarted)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _selectRandomText,
              tooltip: 'Yeni Metin',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ThemeConstants.lightPrimaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hız: $wordsPerMinute kelime/dk',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kelime: $totalWords',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isExerciseStarted)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            text,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'Okuma Hızı:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: wordsPerMinute.toDouble(),
                                  min: 100,
                                  max: 500,
                                  divisions: 40,
                                  label: '$wordsPerMinute kelime/dk',
                                  onChanged: (value) =>
                                      updateSpeed(value.round()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeConstants.lightPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeConstants.lightPrimaryColor,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      currentWord,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isExerciseStarted ? stopExercise : startExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.lightPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      isExerciseStarted ? 'Durdur' : 'Başla',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
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
