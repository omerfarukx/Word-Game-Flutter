import 'dart:async';
import 'package:flutter/material.dart';
import '../models/word_recognition_exercise.dart';

class WordRecognitionWidget extends StatefulWidget {
  final WordRecognitionExercise exercise;
  final Function(int score, double accuracy) onComplete;

  const WordRecognitionWidget({
    Key? key,
    required this.exercise,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<WordRecognitionWidget> createState() => _WordRecognitionWidgetState();
}

class _WordRecognitionWidgetState extends State<WordRecognitionWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Timer _showWordTimer;
  late TextEditingController _answerController;
  late List<String> _currentWords;
  late double _currentShowDuration;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  int _remainingSeconds = 0;
  int _score = 0;
  int _totalAttempts = 0;
  bool _isShowingWord = false;
  bool _canAnswer = false;

  final List<String> _easyWords = [
    'kitap',
    'kalem',
    'masa',
    'kapı',
    'pencere',
    'bahçe',
    'çanta',
    'telefon',
    'bilgisayar',
    'defter'
  ];

  final List<String> _mediumWords = [
    'kütüphane',
    'bilgisayar',
    'televizyon',
    'öğretmen',
    'hastane',
    'üniversite',
    'restoran',
    'otomobil',
    'mühendis',
    'teknoloji'
  ];

  final List<String> _hardWords = [
    'sürdürülebilirlik',
    'karakteristik',
    'profesyonel',
    'optimizasyon',
    'metodoloji',
    'entegrasyon',
    'koordinasyon',
    'standardizasyon',
    'senkronizasyon',
    'kategorileştirme'
  ];

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _currentShowDuration = widget.exercise.initialShowDuration;
    _remainingSeconds = widget.exercise.durationInSeconds;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _startExercise();
  }

  @override
  void dispose() {
    _timer.cancel();
    _showWordTimer.cancel();
    _answerController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startExercise() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeExercise();
        }
      });
    });
    _showNextWord();
  }

  void _showNextWord() {
    setState(() {
      _currentWords = _getRandomWords();
      _isShowingWord = true;
      _canAnswer = false;
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    _showWordTimer =
        Timer(Duration(milliseconds: _currentShowDuration.toInt()), () {
      setState(() {
        _isShowingWord = false;
        _canAnswer = true;
      });
    });
  }

  List<String> _getRandomWords() {
    final List<String> wordPool =
        widget.exercise.difficulty == WordDifficulty.easy
            ? _easyWords
            : widget.exercise.difficulty == WordDifficulty.medium
                ? _mediumWords
                : _hardWords;

    wordPool.shuffle();
    return wordPool.take(widget.exercise.wordsPerRound).toList();
  }

  void _checkAnswer() {
    if (!_canAnswer) return;

    final String userAnswer = _answerController.text.trim().toLowerCase();
    final List<String> correctWords =
        _currentWords.map((w) => w.toLowerCase()).toList();

    bool isCorrect = correctWords.contains(userAnswer);

    setState(() {
      if (isCorrect) {
        _score++;
        _currentShowDuration =
            (_currentShowDuration - widget.exercise.showDurationDecrease).clamp(
                widget.exercise.minShowDuration,
                widget.exercise.initialShowDuration);
      }
      _totalAttempts++;
    });

    _answerController.clear();

    if (_remainingSeconds > 0) {
      _showNextWord();
    } else {
      _completeExercise();
    }
  }

  void _completeExercise() {
    _timer.cancel();
    final double accuracy =
        _totalAttempts > 0 ? (_score / _totalAttempts) * 100 : 0;
    widget.onComplete(_score, accuracy);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.exercise.textColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: widget.exercise.textColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Kalan Süre: $_remainingSeconds saniye',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.exercise.textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        AnimatedOpacity(
          opacity: _isShowingWord ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.exercise.textColor.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.exercise.textColor.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: _currentWords
                    .map((word) => Text(
                          word,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: widget.exercise.textColor,
                            letterSpacing: 1.2,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        if (!_isShowingWord) ...[
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _answerController,
              enabled: _canAnswer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Gördüğünüz kelimeyi yazın',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: widget.exercise.textColor.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: widget.exercise.textColor.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: widget.exercise.textColor,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: _canAnswer
                        ? widget.exercise.textColor
                        : Colors.grey.withOpacity(0.4),
                  ),
                  onPressed: _canAnswer ? _checkAnswer : null,
                ),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: widget.exercise.textColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.score,
                  color: widget.exercise.textColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Skor: $_score / $_totalAttempts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.exercise.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
