import 'package:flutter/material.dart';
import 'dart:math';
import '../../../data/word_pairs_data.dart';
import '../../../data/achievements_data.dart';
import '../../../domain/models/achievement.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class WordPairsScreen extends StatefulWidget {
  const WordPairsScreen({super.key});

  @override
  State<WordPairsScreen> createState() => _WordPairsScreenState();
}

class _WordPairsScreenState extends State<WordPairsScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, List<String>>> wordPairs = WordPairsData.wordPairs;
  final List<Achievement> achievements = AchievementsData.achievements;
  final AudioPlayer _audioPlayer = AudioPlayer();

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
  bool hasJoker = true;

  // Yeni özellikler için değişkenler
  int comboCount = 0;
  int maxComboCount = 0;
  bool hasHint = true;
  bool hasElimination = true;
  List<Achievement> unlockedAchievements = [];
  bool isPerfectRound = true;
  int noHintRoundsCount = 0;

  static const int maxTime = 45;
  static const int minTime = 20;
  static const int timeDecreasePerLevel = 5;

  // Ses dosyaları
  static const String correctSound = 'sounds/correct.mp3';
  static const String wrongSound = 'sounds/wrong.mp3';
  static const String comboSound = 'sounds/combo.mp3';
  static const String achievementSound = 'sounds/achievement.mp3';
  static const String levelUpSound = 'sounds/level_up.mp3';

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
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    try {
      await _audioPlayer.setSourceAsset(correctSound);
    } catch (e) {
      print('Ses yükleme hatası: $e');
    }
  }

  void _playSound(String soundFile) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSourceAsset(soundFile);
      await _audioPlayer.resume();
    } catch (e) {
      print('Ses çalma hatası: $e');
    }
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
    hasJoker = true;
    if (!isGameStarted) {
      score = 0;
      currentLevel = 1;
      timeLeft = maxTime;
    } else {
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

        // Kombo sistemi
        comboCount++;
        if (comboCount > maxComboCount) {
          maxComboCount = comboCount;
        }

        // Puan hesaplama (kombo bonusu ile)
        int baseScore = 20;
        int comboBonus = (comboCount ~/ 3) * 10; // Her 3 komboda +10 puan
        score += baseScore + comboBonus;

        // Zaman bonusu
        int timeBonus = timeLeft > 30 ? 5 : 3;
        timeLeft += timeBonus;

        if (score > highScore) {
          highScore = score;
        }

        correctCards[index] = true;
        consecutiveErrors = 0;

        _playSound(correctSound);
        if (comboCount >= 3) {
          _playSound(comboSound);
        }

        if (remainingWords == 0) {
          _playSound(levelUpSound);
          currentLevel++;
          if (!hasHint && !hasElimination) {
            noHintRoundsCount++;
          }
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              final currentScore = score;
              _initializeGame();
              score = currentScore;
            });
          });
        }

        _checkAchievements();
      } else {
        wrongCards[index] = true;
        setState(() {
          isWrongAnswer = true;
          isPerfectRound = false;
          comboCount = 0; // Komboyu sıfırla
        });
        _playSound(wrongSound);
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

  void _useJoker() {
    if (!hasJoker || !isGameStarted) return;

    List<int> unselectedCorrectCards = [];
    for (int i = 0; i < currentPairs.length; i++) {
      if (!selectedCards[i] && !correctCards[i]) {
        final selectedWord = currentPairs[i];
        if (selectedWord.values.first.split('\n')[0] !=
            selectedWord.values.first.split('\n')[1]) {
          unselectedCorrectCards.add(i);
        }
      }
    }

    if (unselectedCorrectCards.isNotEmpty) {
      final random = Random();
      final selectedIndex =
          unselectedCorrectCards[random.nextInt(unselectedCorrectCards.length)];

      setState(() {
        hasJoker = false;
        _handleCardTap(selectedIndex);
      });
    }
  }

  void _useHint() {
    if (!hasHint || !isGameStarted) return;

    // Doğru kartlardan birini yanıp söndür
    List<int> unselectedCorrectCards = [];
    for (int i = 0; i < currentPairs.length; i++) {
      if (!selectedCards[i] && !correctCards[i]) {
        final selectedWord = currentPairs[i];
        if (selectedWord.values.first.split('\n')[0] !=
            selectedWord.values.first.split('\n')[1]) {
          unselectedCorrectCards.add(i);
        }
      }
    }

    if (unselectedCorrectCards.isNotEmpty) {
      final random = Random();
      final hintIndex =
          unselectedCorrectCards[random.nextInt(unselectedCorrectCards.length)];

      setState(() {
        hasHint = false;
        // Kartı yanıp söndür
        _flashCard(hintIndex);
      });
    }
  }

  void _useElimination() {
    if (!hasElimination || !isGameStarted) return;

    // 1 yanlış kartı ele
    List<int> wrongCardIndexes = [];
    for (int i = 0; i < currentPairs.length; i++) {
      if (!selectedCards[i] && !correctCards[i]) {
        final selectedWord = currentPairs[i];
        if (selectedWord.values.first.split('\n')[0] ==
            selectedWord.values.first.split('\n')[1]) {
          wrongCardIndexes.add(i);
        }
      }
    }

    if (wrongCardIndexes.isNotEmpty) {
      wrongCardIndexes.shuffle();
      setState(() {
        hasElimination = false;
        selectedCards[wrongCardIndexes[0]] = true;
        correctCards[wrongCardIndexes[0]] = true;
      });
    }
  }

  void _flashCard(int index) async {
    for (int i = 0; i < 3; i++) {
      if (!mounted) return;
      setState(() {
        selectedCards[index] = true;
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      setState(() {
        selectedCards[index] = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (!unlockedAchievements.contains(achievement)) {
        bool shouldUnlock = false;

        switch (achievement.id) {
          case 'first_win':
            shouldUnlock = currentLevel > 1;
            break;
          case 'combo_master':
            shouldUnlock = maxComboCount >= 5;
            break;
          case 'speed_demon':
            shouldUnlock = timeLeft > 25;
            break;
          case 'perfect_round':
            shouldUnlock = isPerfectRound && remainingWords == 0;
            break;
          case 'hint_master':
            shouldUnlock = noHintRoundsCount >= 3;
            break;
        }

        if (shouldUnlock) {
          setState(() {
            unlockedAchievements.add(achievement);
          });
          _showAchievementDialog(achievement);
          _playSound(achievementSound);
        }
      }
    }
  }

  void _showAchievementDialog(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Başarı Kazanıldı!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(achievement.badgeAsset, height: 100),
            SizedBox(height: 16),
            Text(
              achievement.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(achievement.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Harika!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _wrongAnimationController.dispose();
    super.dispose();
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
        actions: [
          if (isGameStarted) ...[
            // İpucu butonu
            IconButton(
              onPressed: hasHint ? _useHint : null,
              icon: Stack(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: hasHint ? Colors.amber : Colors.grey,
                  ),
                  if (hasHint)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'İpucu Kullan',
            ),
            // Eleme butonu
            IconButton(
              onPressed: hasElimination ? _useElimination : null,
              icon: Stack(
                children: [
                  Icon(
                    Icons.remove_circle_outline,
                    color: hasElimination ? Colors.amber : Colors.grey,
                  ),
                  if (hasElimination)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Eleme Kullan',
            ),
            // Joker butonu
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: hasJoker ? _useJoker : null,
                icon: Stack(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: hasJoker ? Colors.amber : Colors.grey,
                    ),
                    if (hasJoker)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Joker Kullan',
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1F2937),
                      const Color(0xFF111827),
                      const Color(0xFF030712),
                    ]
                  : [
                      const Color(0xFF0F766E),
                      const Color(0xFF0D9488),
                      const Color(0xFF0F766E),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Column(
            children: [
              Container(
                height: infoHeight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1F2937).withOpacity(0.9)
                      : Colors.white.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoCard(
                          icon: Icons.star,
                          label: 'Puan',
                          value: score.toString(),
                          isDark: isDark,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                          ),
                        ),
                        _buildInfoCard(
                          icon: Icons.emoji_events,
                          label: 'En Yüksek',
                          value: highScore.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
                          ),
                          isDark: isDark,
                        ),
                        _buildInfoCard(
                          icon: Icons.timer,
                          label: 'Süre',
                          value: timeLeft.toString(),
                          gradient: LinearGradient(
                            colors: timeLeft < 10
                                ? const [Color(0xFFDC2626), Color(0xFFB91C1C)]
                                : const [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                          ),
                          isDark: isDark,
                        ),
                        _buildInfoCard(
                          icon: Icons.trending_up,
                          label: 'Bölüm',
                          value: currentLevel.toString(),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: currentPairs.length,
                  itemBuilder: (context, index) {
                    final pair = currentPairs[index];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: selectedCards[index] ? 12 : 4,
                        margin: const EdgeInsets.all(1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                correctCards[index]
                                    ? (pair.values.first.split('\n')[0] ==
                                            pair.values.first.split('\n')[1]
                                        ? (isDark
                                            ? const Color(0xFF374151)
                                            : const Color(0xFF115E59))
                                        : (isDark
                                            ? const Color(0xFF047857)
                                            : const Color(0xFF0F766E)))
                                    : wrongCards[index]
                                        ? Color.lerp(
                                            isDark
                                                ? const Color(0xFF1F2937)
                                                : Colors.white
                                                    .withOpacity(0.15),
                                            const Color(0xFFDC2626),
                                            _wrongAnimationController.value,
                                          )!
                                        : selectedCards[index]
                                            ? (isDark
                                                ? const Color(0xFF059669)
                                                : const Color(0xFF0D9488))
                                            : (isDark
                                                ? const Color(0xFF1F2937)
                                                : Colors.white
                                                    .withOpacity(0.15)),
                                correctCards[index]
                                    ? (pair.values.first.split('\n')[0] ==
                                            pair.values.first.split('\n')[1]
                                        ? (isDark
                                            ? const Color(0xFF4B5563)
                                            : const Color(0xFF0F766E))
                                        : (isDark
                                            ? const Color(0xFF065F46)
                                            : const Color(0xFF0D9488)))
                                    : wrongCards[index]
                                        ? Color.lerp(
                                            isDark
                                                ? const Color(0xFF374151)
                                                : Colors.white
                                                    .withOpacity(0.25),
                                            const Color(0xFFB91C1C),
                                            _wrongAnimationController.value,
                                          )!
                                        : selectedCards[index]
                                            ? (isDark
                                                ? const Color(0xFF047857)
                                                : const Color(0xFF0F766E))
                                            : (isDark
                                                ? const Color(0xFF374151)
                                                : Colors.white
                                                    .withOpacity(0.25)),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (correctCards[index] ||
                                        selectedCards[index])
                                    ? const Color(0xFF0D9488).withOpacity(0.3)
                                    : Colors.black.withOpacity(0.1),
                                blurRadius: selectedCards[index] ? 12 : 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _handleCardTap(index),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: pair.values.first
                                      .split('\n')
                                      .map(
                                        (word) => FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            word,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isGameStarted)
                Container(
                  width: double.infinity,
                  height: 56,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'OYUNU BAŞLAT',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
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
    required bool isDark,
    Color? color,
    Gradient? gradient,
  }) {
    final defaultColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (color ?? defaultColor).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
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
