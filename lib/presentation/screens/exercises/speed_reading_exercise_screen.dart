import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;
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
          backgroundColor: primaryColor,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 100,
                  color: primaryColor,
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
                    backgroundColor: primaryColor,
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
        backgroundColor: primaryColor,
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.2),
              Colors.white,
              primaryColor.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard(
                        icon: Icons.speed,
                        title: 'Hız',
                        value: '$wordsPerMinute kelime/dk',
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                      ),
                      _buildInfoCard(
                        icon: Icons.text_fields,
                        title: 'Kelime',
                        value: '$totalWords',
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.purple.shade600
                          ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Okuma Hızını Ayarla',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.speed, color: primaryColor),
                                    Expanded(
                                      child: Slider(
                                        value: wordsPerMinute.toDouble(),
                                        min: 100,
                                        max: 500,
                                        divisions: 40,
                                        label: '$wordsPerMinute kelime/dk',
                                        activeColor: primaryColor,
                                        onChanged: (value) =>
                                            updateSpeed(value.round()),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 24),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.9),
                          primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      currentWord,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
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
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isExerciseStarted ? Icons.stop : Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(
                          isExerciseStarted ? 'Durdur' : 'Başla',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
