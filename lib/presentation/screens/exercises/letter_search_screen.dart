import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../presentation/controllers/letter_search_game_controller.dart';
import '../../../presentation/widgets/letter_search/letter_search_grid.dart';
import '../../../presentation/widgets/letter_search/target_words_display.dart';
import '../../../presentation/widgets/letter_search/score_board.dart';
import '../../../presentation/widgets/letter_search/game_dialogs.dart';
import '../../../data/achievements_data.dart';
import '../../../domain/models/achievement.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

class LetterSearchScreen extends StatefulWidget {
  const LetterSearchScreen({super.key});

  @override
  State<LetterSearchScreen> createState() => _LetterSearchScreenState();
}

class _LetterSearchScreenState extends State<LetterSearchScreen> {
  final _gameController = LetterSearchGameController();
  final List<Achievement> achievements = AchievementsData.achievements;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late SharedPreferences _prefs;

  // Yeni özellikler için değişkenler
  List<Achievement> unlockedAchievements = [];
  bool hasFirstJoker = true; // İlk harfi gösteren joker
  bool hasSecondJoker = true; // Tüm kelimeyi gösteren joker
  int comboCount = 0;
  int maxComboCount = 0;
  bool isPerfectRound = true;
  int noHintRoundsCount = 0;

  // Ses dosyaları
  static const String correctSound = 'sounds/correct.mp3';
  static const String wrongSound = 'sounds/wrong.mp3';
  static const String comboSound = 'sounds/combo.mp3';
  static const String achievementSound = 'sounds/achievement.mp3';
  static const String levelUpSound = 'sounds/level_up.mp3';

  int _countDown = 3;

  @override
  void initState() {
    super.initState();
    _gameController.initializeGame();
    _initPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showStartDialog();
      }
    });
    _loadSounds();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      // Kayıtlı başarıları yükle
      final savedAchievements =
          _prefs.getStringList('unlockedAchievements') ?? [];
      unlockedAchievements = achievements
          .where((achievement) => savedAchievements.contains(achievement.id))
          .toList();
    });
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

  @override
  void dispose() {
    _gameController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showStartDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyunu Başlat'),
          content: const Text('Hazır olduğunuzda başlayabilirsiniz!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startCountDown();
              },
              child: const Text('BAŞLAT'),
            ),
          ],
        );
      },
    );
  }

  void _startCountDown() {
    if (!mounted) return;

    void showCountDialog(int count) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              count == 0 ? "BAŞLA!" : count.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          );
        },
      );
    }

    showCountDialog(3);

    Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      showCountDialog(2);
    });

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      showCountDialog(1);
    });

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      showCountDialog(0);
    });

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() {
        _countDown = 3;
        _gameController.isGameStarted = true;
        _startGame();
      });
    });
  }

  void _startGame() {
    _gameController.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_gameController.foundWordsCount >=
            _gameController.targetWords.length) {
          _playSound(levelUpSound);
          _checkAchievements();
          _gameController.refreshGame();
          return;
        }

        if (_gameController.timeLeft > 0) {
          _gameController.timeLeft--;
        } else {
          _gameOver();
        }
      });
    });
  }

  void _handleWordFound() {
    _playSound(correctSound);
    comboCount++;
    if (comboCount > maxComboCount) {
      maxComboCount = comboCount;
    }
    if (comboCount >= 3) {
      _playSound(comboSound);
    }
    // Zaman bonusu
    setState(() {
      _gameController.timeLeft += _gameController.timeLeft > 30 ? 5 : 3;
      _gameController.score += comboCount >= 3 ? 15 : 10; // Kombo bonusu
    });
  }

  void _handleWrongSelection() {
    _playSound(wrongSound);
    setState(() {
      comboCount = 0;
      isPerfectRound = false;
      _gameController.timeLeft =
          _gameController.timeLeft > 5 ? _gameController.timeLeft - 5 : 0;
      _gameController.score = max(0, _gameController.score - 5);
    });
  }

  bool _checkWordAtPosition(int row, int col, String word, int direction) {
    if ((direction == 0 && col + word.length > 10) || // yatay
        (direction == 1 && row + word.length > 10) || // dikey
        (direction == 2 &&
            (row + word.length > 10 || col + word.length > 10))) {
      // çapraz
      return false;
    }

    for (int i = 0; i < word.length; i++) {
      int checkRow = row + (direction == 0 ? 0 : i);
      int checkCol = col + (direction == 1 ? 0 : i);
      if (_gameController.currentGrid[checkRow][checkCol] != word[i]) {
        return false;
      }
    }
    return true;
  }

  void _useFirstJoker() {
    if (!hasFirstJoker || !_gameController.isGameStarted) return;
    setState(() {
      hasFirstJoker = false;
      // Henüz bulunmamış bir kelimenin ilk harfini göster
      List<String> remainingWords = _gameController.targetWords
          .where((word) => !_gameController.foundWords.contains(word))
          .toList();

      if (remainingWords.isNotEmpty) {
        final random = Random();
        final targetWord =
            remainingWords[random.nextInt(remainingWords.length)];

        // Kelimenin ilk harfini bul
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (_gameController.currentGrid[i][j] == targetWord[0]) {
              // Tüm yönleri kontrol et
              for (int direction = 0; direction < 8; direction++) {
                if (_checkWordAtPosition(i, j, targetWord, direction)) {
                  // Sadece ilk harfi işaretle
                  _gameController.hintPositions = List.generate(
                      10, (row) => List.generate(10, (col) => false));
                  _gameController.hintPositions[i][j] = true;
                  return;
                }
              }
            }
          }
        }
      }
      isPerfectRound = false;
    });
  }

  void _useSecondJoker() {
    if (!hasSecondJoker || !_gameController.isGameStarted) return;
    setState(() {
      hasSecondJoker = false;
      // Henüz bulunmamış bir kelimenin tüm harflerini göster
      List<String> remainingWords = _gameController.targetWords
          .where((word) => !_gameController.foundWords.contains(word))
          .toList();

      if (remainingWords.isNotEmpty) {
        final random = Random();
        final targetWord =
            remainingWords[random.nextInt(remainingWords.length)];

        // Kelimeyi tahtada bul
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (_gameController.currentGrid[i][j] == targetWord[0]) {
              // Tüm yönleri kontrol et
              for (int direction = 0; direction < 8; direction++) {
                if (_checkWordAtPosition(i, j, targetWord, direction)) {
                  _highlightWord(i, j, targetWord.length, direction);
                  return;
                }
              }
            }
          }
        }
      }
      isPerfectRound = false;
    });
  }

  void _highlightWord(int startRow, int startCol, int length, int direction) {
    final directions = [
      [0, 1], // sağa
      [1, 0], // aşağı
      [1, 1], // sağ aşağı çapraz
      [-1, 1], // sağ yukarı çapraz
      [0, -1], // sola
      [-1, 0], // yukarı
      [-1, -1], // sol yukarı çapraz
      [1, -1] // sol aşağı çapraz
    ];

    int dRow = directions[direction][0];
    int dCol = directions[direction][1];

    for (int i = 0; i < length; i++) {
      int row = startRow + dRow * i;
      int col = startCol + dCol * i;
      _gameController.hintPositions[row][col] = true;
    }
  }

  void _gameOver() {
    _gameController.timer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oyun Bitti!'),
          content: Text('Skorunuz: ${_gameController.score}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('Yeniden Başla'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _gameController.isGameStarted = false;
      _gameController.initializeGame();
      _countDown = 3;
      hasFirstJoker = true;
      hasSecondJoker = true;
      comboCount = 0;
      isPerfectRound = true;
      _showStartDialog();
    });
  }

  void _checkAchievements() {
    for (var achievement in achievements) {
      if (!unlockedAchievements.contains(achievement)) {
        bool shouldUnlock = false;

        switch (achievement.id) {
          case 'first_win':
            shouldUnlock = _gameController.score >= 100;
            break;
          case 'combo_master':
            shouldUnlock = maxComboCount >= 5;
            break;
          case 'speed_demon':
            shouldUnlock = _gameController.timeLeft > 25;
            break;
          case 'perfect_round':
            shouldUnlock = isPerfectRound &&
                _gameController.foundWordsCount >=
                    _gameController.targetWords.length;
            break;
          case 'hint_master':
            shouldUnlock = noHintRoundsCount >= 3;
            break;
        }

        if (shouldUnlock) {
          setState(() {
            unlockedAchievements.add(achievement);
            // Başarıyı kalıcı olarak kaydet
            final savedAchievements =
                unlockedAchievements.map((a) => a.id).toList();
            _prefs.setStringList('unlockedAchievements', savedAchievements);
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Harf Arama',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.teal.shade700 : Colors.teal,
        actions: [
          if (_gameController.isGameStarted) ...[
            // İlk Joker butonu
            IconButton(
              onPressed: hasFirstJoker ? _useFirstJoker : null,
              icon: Stack(
                children: [
                  Icon(
                    Icons.front_hand,
                    color: hasFirstJoker ? Colors.amber : Colors.grey,
                  ),
                  if (hasFirstJoker)
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
              tooltip: 'İlk Harf Joker',
            ),
            // İkinci Joker butonu
            IconButton(
              onPressed: hasSecondJoker ? _useSecondJoker : null,
              icon: Stack(
                children: [
                  Icon(
                    Icons.auto_fix_high,
                    color: hasSecondJoker ? Colors.amber : Colors.grey,
                  ),
                  if (hasSecondJoker)
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
              tooltip: 'Tam Kelime Joker',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Nasıl Oynanır?',
            onPressed: () => GameDialogs.showHelpDialog(context),
          ),
        ],
      ),
      body: Container(
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
        child: Stack(
          children: [
            Column(
              children: [
                TargetWordsDisplay(
                  targetWords: _gameController.targetWords,
                  foundWords: _gameController.foundWords,
                ),
                Expanded(
                  child: LetterSearchGrid(
                    currentGrid: _gameController.currentGrid,
                    selectedCells: _gameController.selectedCells,
                    foundCells: _gameController.foundCells,
                    hintPositions: _gameController.hintPositions,
                    onCellTap: (row, col) {
                      if (_gameController.handleCellSelection(row, col)) {
                        setState(() {
                          if (_gameController.isWordFound) {
                            _handleWordFound();
                          } else if (_gameController.isWrongSelection) {
                            _handleWrongSelection();
                          }
                        });
                      }
                    },
                  ),
                ),
                ScoreBoard(
                  score: _gameController.score,
                  foundWordsCount: _gameController.foundWordsCount,
                  totalWords: _gameController.targetWords.length,
                  timeLeft: _gameController.timeLeft,
                ),
              ],
            ),
            if (!_gameController.isGameStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
