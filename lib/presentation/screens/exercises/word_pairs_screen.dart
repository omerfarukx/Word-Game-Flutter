import 'package:flutter/material.dart';
import 'dart:math';
import '../../../data/word_pairs_data.dart';
import 'package:google_fonts/google_fonts.dart';

class WordPairsScreen extends StatefulWidget {
  const WordPairsScreen({super.key});

  @override
  State<WordPairsScreen> createState() => _WordPairsScreenState();
}

class _WordPairsScreenState extends State<WordPairsScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, List<String>>> wordPairs = WordPairsData.wordPairs;
  List<Map<String, String>> currentPairs = [];
  List<bool> selectedCards = [];
  List<bool> correctCards = [];
  List<bool> wrongCards = [];
  int remainingWords = 5;
  int score = 0;
  int highScore = 0;
  bool isGameStarted = false;
  int timeLeft = 45;
  int currentLevel = 1;
  int consecutiveErrors = 0;
  bool isWrongAnswer = false;

  static const int maxTime = 45;
  static const int minTime = 20;
  static const int timeDecreasePerLevel = 5;

  late AnimationController _wrongAnimationController;

  @override
  void initState() {
    super.initState();
    _wrongAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _wrongAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _wrongAnimationController.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          isWrongAnswer = false;
        });
      }
    });
    _initializeGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRulesDialog();
    });
  }

  @override
  void dispose() {
    _wrongAnimationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final random = Random();
    final shuffledPairs = List.from(wordPairs)..shuffle(random);
    final selectedWords = shuffledPairs.take(15).toList();
    currentPairs = [];

    for (int i = 0; i < 5; i++) {
      var word = selectedWords[i];
      currentPairs.add({word.keys.first: word.values.first[1]});
    }

    for (int i = 5; i < 15; i++) {
      var word = selectedWords[i];
      currentPairs.add({word.keys.first: word.values.first[0]});
    }

    currentPairs.shuffle(random);
    selectedCards = List.generate(15, (index) => false);
    correctCards = List.generate(15, (index) => false);
    wrongCards = List.generate(15, (index) => false);
    remainingWords = 5;
    if (!isGameStarted) {
      score = 0;
      currentLevel = 1;
      timeLeft = maxTime;
    } else {
      // Bölüm geçildiğinde süreyi azalt
      timeLeft =
          max(minTime, maxTime - ((currentLevel - 1) * timeDecreasePerLevel));
    }
  }

  void _handleCardTap(int index) {
    if (!isGameStarted || selectedCards[index] || correctCards[index]) return;

    setState(() {
      selectedCards[index] = true;

      final selectedWord = currentPairs[index];
      final originalWord = wordPairs.firstWhere(
        (pair) => pair.keys.first == selectedWord.keys.first,
        orElse: () => {
          selectedWord.keys.first: [
            selectedWord.values.first,
            selectedWord.values.first
          ]
        },
      );

      if (selectedWord.values.first.split('\n')[0] !=
          selectedWord.values.first.split('\n')[1]) {
        remainingWords--;
        score += 20;
        if (score > highScore) {
          highScore = score;
        }
        correctCards[index] = true;
        consecutiveErrors = 0;

        if (remainingWords == 0) {
          currentLevel++; // Bölüm geçildiğinde seviyeyi arttır
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              final currentScore = score;
              _initializeGame();
              score = currentScore;
            });
          });
        }
      } else {
        wrongCards[index] = true;
        setState(() {
          isWrongAnswer = true;
        });
        _wrongAnimationController.forward(from: 0);
        consecutiveErrors++;

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              selectedCards[index] = false;
              wrongCards[index] = false;
              score = max(0, score - 10);
              int timePenalty = 5 + (consecutiveErrors - 1) * 2;
              timeLeft = max(0, timeLeft - timePenalty);
            });
          }
        });
      }
    });
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
    });
    _showCountdown();
  }

  void _showCountdown() {
    void showCountDialog(int count) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              count == 0 ? "BAŞLA!" : count.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.teal,
              ),
            ),
          );
        },
      );
    }

    showCountDialog(3);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      showCountDialog(2);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.of(context).pop();
        showCountDialog(1);

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.of(context).pop();
          showCountDialog(0);

          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            Navigator.of(context).pop();
            _startTimer();
          });
        });
      });
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        timeLeft--;
      });
      if (timeLeft > 0) {
        _startTimer();
      } else {
        _showGameOver();
      }
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Oyun Bitti!',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Toplam Puanınız: $score',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isGameStarted = false;
                  _initializeGame();
                });
              },
              child: Text(
                'YENİDEN OYNA',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.teal,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Oyun Kuralları',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRuleItem(
                '1. Kartlardaki kelime çiftlerinden farklı yazılanları bulun.',
                Icons.difference_rounded,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '2. Her doğru eşleştirme için 20 puan kazanırsınız.',
                Icons.add_circle_outline_rounded,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '3. Her yanlış seçimde 10 puan kaybedersiniz.',
                Icons.remove_circle_outline_rounded,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '4. Yanlış seçimlerde sürenizden düşer.',
                Icons.timer_off_outlined,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '5. Her bölümde süre 5 saniye azalır.',
                Icons.trending_down_rounded,
              ),
              SizedBox(height: 12),
              _buildRuleItem(
                '6. Her turda 5 farklı kelime çifti bulmalısınız.',
                Icons.grid_view_rounded,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ANLADIM',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuleItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.teal,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = screenSize.height -
        padding.top -
        padding.bottom -
        AppBar().preferredSize.height;

    const infoHeight = 80.0;
    const buttonHeight = 40.0;

    final gridHeight =
        availableHeight - infoHeight - (isGameStarted ? 0 : buttonHeight) - 16;

    final itemWidth = (screenSize.width - 24) / 3;
    final itemHeight = (gridHeight - 40) / 5;
    final aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aynı Olmayan Kelime Çiftleri',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.teal.shade700 : Colors.teal,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.grey.shade900,
                      Colors.black,
                    ]
                  : [
                      Colors.teal.shade50,
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            children: [
              Container(
                height: infoHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LinearProgressIndicator(
                      value: timeLeft / 45,
                      backgroundColor:
                          isDark ? Colors.grey.shade700 : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isWrongAnswer ? Colors.red : Colors.amber,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard(
                          icon: Icons.stars,
                          label: 'Puan',
                          value: score.toString(),
                          isDark: isDark,
                        ),
                        _buildInfoCard(
                          icon: Icons.emoji_events,
                          label: 'En Yüksek',
                          value: highScore.toString(),
                          color: Colors.amber,
                          isDark: isDark,
                        ),
                        _buildInfoCard(
                          icon: Icons.timer,
                          label: 'Süre',
                          value: timeLeft.toString(),
                          color: timeLeft < 10 ? Colors.red : null,
                          isDark: isDark,
                        ),
                        _buildInfoCard(
                          icon: Icons.trending_up,
                          label: 'Bölüm',
                          value: currentLevel.toString(),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: currentPairs.length,
                  itemBuilder: (context, index) {
                    final pair = currentPairs[index];
                    return AnimatedBuilder(
                      animation: _wrongAnimationController,
                      builder: (context, child) {
                        Color cardColor =
                            isDark ? Colors.grey.shade800 : Colors.white;
                        if (correctCards[index]) {
                          cardColor =
                              isDark ? Colors.green.shade700 : Colors.green;
                        } else if (wrongCards[index]) {
                          cardColor = Color.lerp(
                            isDark ? Colors.grey.shade800 : Colors.white,
                            isDark ? Colors.red.shade700 : Colors.red,
                            _wrongAnimationController.value,
                          )!;
                        } else if (selectedCards[index]) {
                          cardColor =
                              isDark ? Colors.teal.shade700 : Colors.teal;
                        }

                        return Card(
                          elevation: selectedCards[index] ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: correctCards[index]
                                  ? (isDark
                                      ? Colors.green.shade700
                                      : Colors.green)
                                  : wrongCards[index]
                                      ? (isDark
                                          ? Colors.red.shade700
                                          : Colors.red)
                                      : selectedCards[index]
                                          ? (isDark
                                              ? Colors.teal.shade700
                                              : Colors.teal)
                                          : (isDark
                                                  ? Colors.teal.shade700
                                                  : Colors.teal)
                                              .withOpacity(0.3),
                              width: selectedCards[index] ? 2 : 1,
                            ),
                          ),
                          color: cardColor,
                          child: InkWell(
                            onTap: isGameStarted
                                ? () => _handleCardTap(index)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: (!selectedCards[index] &&
                                        !correctCards[index] &&
                                        !wrongCards[index])
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                Colors.grey.shade800,
                                                Colors.grey.shade900,
                                              ]
                                            : [
                                                Colors.white,
                                                Colors.teal.shade50,
                                              ],
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    pair.values.first,
                                    textAlign: TextAlign.center,
                                    style: _getCardTextStyle(
                                      isDark: isDark,
                                      isCorrect: correctCards[index],
                                      isSelected: selectedCards[index],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (!isGameStarted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: screenSize.width * 0.6,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.teal.shade700 : Colors.teal,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'OYUNU BAŞLAT',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.grey.shade100 : Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
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

  Color _getTextColor({
    required bool isDark,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (isCorrect || isSelected) {
      return isDark ? Colors.grey.shade100 : Colors.white;
    }
    return isDark ? Colors.grey.shade100 : Colors.black87;
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    required bool isDark,
  }) {
    final defaultColor = isDark ? Colors.teal.shade300 : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? defaultColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? defaultColor).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color ?? defaultColor,
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: color ?? defaultColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: color ?? defaultColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (label == 'Bölüm')
                Icon(
                  Icons.arrow_upward,
                  color: color ?? defaultColor,
                  size: 12,
                ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _getCardTextStyle({
    required bool isDark,
    required bool isCorrect,
    required bool isSelected,
  }) {
    return GoogleFonts.nunito(
      fontSize: 16,
      color: _getTextColor(
        isDark: isDark,
        isCorrect: isCorrect,
        isSelected: isSelected,
      ),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      height: 1.5,
    );
  }
}
