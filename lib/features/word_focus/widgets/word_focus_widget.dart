import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_focus_game.dart';
import '../models/word_pair.dart';

class WordFocusWidget extends StatefulWidget {
  final WordFocusGame game;
  final WordPair wordPair;
  final Function(int score, double accuracy) onComplete;

  const WordFocusWidget({
    Key? key,
    required this.game,
    required this.wordPair,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<WordFocusWidget> createState() => _WordFocusWidgetState();
}

class _WordFocusWidgetState extends State<WordFocusWidget>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _remainingTime = 0;
  int _score = 0;
  int _attempts = 0;
  Set<String> _foundWords = {};
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.game.duration;
    _setupAnimations();
    _startGame();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _pulseController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _pulseController.forward();
        }
      });

    _pulseController.forward();
  }

  void _startGame() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    _timer.cancel();
    final accuracy = _attempts > 0 ? _score / _attempts * 100 : 0.0;
    widget.onComplete(_score, accuracy);
  }

  void _handleWordTap(String word) {
    setState(() {
      _attempts++;
      if (widget.wordPair.correctWords.contains(word) &&
          !_foundWords.contains(word)) {
        _foundWords.add(word);
        _score += 10;
        if (_foundWords.length == widget.wordPair.correctWords.length) {
          _endGame();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    // Oyun tipine göre bilgi mesajı
    String getInfoMessage() {
      switch (widget.game.type) {
        case WordGameType.synonyms:
          return 'Ortadaki kelimenin eş anlamlılarını seçin';
        case WordGameType.antonyms:
          return 'Ortadaki kelimenin zıt anlamlılarını seçin';
        case WordGameType.wordFamily:
          return 'Ortadaki kelimeden türeyen kelimeleri seçin';
        case WordGameType.category:
          return 'Ortadaki kelime ile aynı kategorideki kelimeleri seçin';
        default:
          return 'Kelimeleri seçin';
      }
    }

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6200EA), // Derin mor
            const Color(0xFF304FFE), // Canlı mavi
          ],
        ),
      ),
      child: Stack(
        children: [
          // Çevredeki kelimeler
          ...List.generate(widget.wordPair.relatedWords.length, (index) {
            final angle =
                (index * 2 * pi) / widget.wordPair.relatedWords.length;
            final wordWidth = 100.0;
            final wordHeight = 45.0;

            return Positioned(
              left: centerX + radius * cos(angle) - (wordWidth / 2),
              top: centerY + radius * sin(angle) - (wordHeight / 2),
              child: GestureDetector(
                onTap: () =>
                    _handleWordTap(widget.wordPair.relatedWords[index]),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _foundWords
                              .contains(widget.wordPair.relatedWords[index])
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.white, Colors.white70],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_foundWords.contains(
                                    widget.wordPair.relatedWords[index])
                                ? Colors.green.shade300
                                : Colors.blue.shade300)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.wordPair.relatedWords[index],
                    style: TextStyle(
                      fontSize: 16,
                      color: _foundWords
                              .contains(widget.wordPair.relatedWords[index])
                          ? Colors.white
                          : const Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Merkezdeki kelime
          Positioned(
            left: centerX - 60,
            top: centerY - 30,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade300, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade300.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  widget.wordPair.mainWord,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          // Minimal bilgi göstergesi
          Positioned(
            top: 120,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.amber.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_remainingTime',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Icon(Icons.stars, color: Colors.pink.shade300, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Üst bilgi yazısı
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    getInfoMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.wordPair.correctWords.length} kelime bulmanız gerekiyor',
                    style: TextStyle(
                      color: Colors.amber.shade300,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
