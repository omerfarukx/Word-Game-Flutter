import 'package:flutter/material.dart';
import 'dart:async';
import '../../../presentation/controllers/letter_search_game_controller.dart';
import '../../../presentation/widgets/letter_search/letter_search_grid.dart';
import '../../../presentation/widgets/letter_search/target_words_display.dart';
import '../../../presentation/widgets/letter_search/score_board.dart';
import '../../../presentation/widgets/letter_search/game_dialogs.dart';

class LetterSearchScreen extends StatefulWidget {
  const LetterSearchScreen({super.key});

  @override
  State<LetterSearchScreen> createState() => _LetterSearchScreenState();
}

class _LetterSearchScreenState extends State<LetterSearchScreen> {
  final _gameController = LetterSearchGameController();
  int _countDown = 3;

  @override
  void initState() {
    super.initState();
    _gameController.initializeGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showStartDialog();
      }
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
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
        if (_gameController.timeLeft > 0) {
          _gameController.timeLeft--;
        } else {
          _gameOver();
        }
      });
    });
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
      _showStartDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harf Arama'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'İpucu Al (-5 puan)',
            onPressed: () => setState(() => _gameController.showHint()),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Seçimi Temizle',
            onPressed: () => setState(() => _gameController.clearSelection()),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Nasıl Oynanır?',
            onPressed: () => GameDialogs.showHelpDialog(context),
          ),
        ],
      ),
      body: Stack(
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
                      setState(() {});
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
                color: Colors.black.withOpacity(0.3), //Opacity 0.3
              ),
            ),
        ],
      ),
    );
  }
}
