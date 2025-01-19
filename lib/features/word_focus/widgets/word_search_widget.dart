import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/word_search_game.dart';

class WordSearchWidget extends StatefulWidget {
  final WordSearchGame game;

  const WordSearchWidget({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  State<WordSearchWidget> createState() => _WordSearchWidgetState();
}

class _WordSearchWidgetState extends State<WordSearchWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  List<String> foundWords = [];
  List<int> selectedIndices = [];
  List<int> foundIndices = [];
  bool isDragging = false;
  late WordSearchGame currentGame;
  late AnimationController _shakeController;
  bool _showCongratulations = false;

  @override
  void initState() {
    super.initState();
    currentGame = widget.game;
    startNewGame();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  void startNewGame() {
    setState(() {
      foundWords.clear();
      selectedIndices.clear();
      foundIndices.clear();
      currentGame = WordSearchGame.easy();
      currentGame.generateGrid();
      _timer?.cancel();
      startTimer();
      _showCongratulations = false;
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentGame.updateTime();
        if (currentGame.isCompleted) {
          _timer?.cancel();
          _showGameOverDialog();
        }
      });
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Oyun Bitti!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreRow('Puanınız:', '${currentGame.score}'),
            _buildScoreRow(
              'Bulunan Kelimeler:',
              '${foundWords.length}/${currentGame.words.length}',
            ),
            const SizedBox(height: 16),
            const Text(
              'Bulunamayan Kelimeler:',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...currentGame.words
                .where((word) => !foundWords.contains(word))
                .map((word) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.close, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            word,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Çıkış'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WordSearchWidget(game: currentGame),
                ),
              );
            },
            child: const Text('Yeni Oyun'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleLetterSelection(int row, int col) {
    final index = row * currentGame.gridSize + col;

    setState(() {
      if (!isDragging) {
        if (selectedIndices.contains(index)) {
          selectedIndices.clear();
        } else {
          if (selectedIndices.isEmpty) {
            selectedIndices.add(index);
          } else {
            List<int> positions = [
              ...selectedIndices.map((idx) {
                int r = idx ~/ currentGame.gridSize;
                int c = idx % currentGame.gridSize;
                return [r, c];
              }).expand((pos) => pos),
              row,
              col
            ];

            if (currentGame.isValidSelection(positions)) {
              selectedIndices.add(index);
              String selectedWord = '';
              for (int idx in selectedIndices) {
                int r = idx ~/ currentGame.gridSize;
                int c = idx % currentGame.gridSize;
                selectedWord += currentGame.grid[r][c];
              }

              if (currentGame.checkWord(selectedWord) &&
                  !foundWords.contains(selectedWord)) {
                _showCongratulations = true;
                foundWords.add(selectedWord);
                foundIndices.addAll(selectedIndices);
                currentGame.updateScore(selectedWord);
                _playSuccessAnimation();

                if (foundWords.length == currentGame.words.length) {
                  _timer?.cancel();
                  currentGame.isCompleted = true;
                  Future.delayed(const Duration(milliseconds: 1500), () {
                    _showVictoryDialog();
                  });
                } else {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    if (mounted) {
                      setState(() {
                        _showCongratulations = false;
                      });
                    }
                  });
                }

                selectedIndices.clear();
              } else if (selectedWord.length >= currentGame.maxWordLength) {
                _shakeController.forward(from: 0);
                selectedIndices.clear();
              }
            }
          }
        }
      }
    });
  }

  void _playSuccessAnimation() {
    // Başarılı kelime bulma animasyonu
  }

  void _showHint() {
    final hint = currentGame.useHint();
    if (hint != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.yellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('İpucu hakkınız kalmadı!'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(8),
        ),
      );
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tebrikler!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tüm kelimeleri ${currentGame.timeLeft} saniye kala buldunuz!',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Toplam Puan: ${currentGame.score}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Çıkış'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              startNewGame();
            },
            child: const Text('Yeni Oyun'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B5E20), // Koyu yeşil
            const Color(0xFF0D47A1), // Koyu mavi
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopPanel(),
                  _buildCategoryInfo(),
                  _buildWordGrid(),
                  _buildFoundWordsList(),
                ],
              ),
              if (_showCongratulations)
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Harika!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoContainer(
            icon: Icons.stars,
            label: 'Puan',
            value: currentGame.score.toString(),
            color: Colors.amber,
          ),
          _buildInfoContainer(
            icon: Icons.timer,
            label: 'Süre',
            value: '${currentGame.timeLeft}s',
            color: Colors.red,
          ),
          _buildHintButton(),
        ],
      ),
    );
  }

  Widget _buildInfoContainer({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, color: Colors.yellow),
            onPressed: _showHint,
            tooltip: 'İpucu (${currentGame.hintsLeft} hak)',
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentGame.hintsLeft}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.category, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            'Kategori: ${currentGame.category.name.toUpperCase()}',
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

  Widget _buildWordGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                sin(_shakeController.value * 4 * 3.14159) * 5,
                0,
              ),
              child: child,
            );
          },
          child: GestureDetector(
            onPanStart: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              isDragging = true;
              _handleGridTouch(localPosition);
            },
            onPanUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              _handleGridTouch(localPosition);
            },
            onPanEnd: (details) {
              setState(() {
                isDragging = false;
                selectedIndices.clear();
              });
            },
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: currentGame.gridSize,
                childAspectRatio: 1.0,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: currentGame.gridSize * currentGame.gridSize,
              itemBuilder: (context, index) {
                final row = index ~/ currentGame.gridSize;
                final col = index % currentGame.gridSize;
                final isSelected = selectedIndices.contains(index);

                return GestureDetector(
                  onTapDown: (_) => _handleLetterSelection(row, col),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: isSelected ? 1 : 0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      final isFound = foundIndices.contains(index);
                      return Transform.scale(
                        scale: 1 + (value * 0.1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isFound
                                  ? [Colors.green[400]!, Colors.green[600]!]
                                  : isSelected
                                      ? [Colors.blue[400]!, Colors.blue[600]!]
                                      : [
                                          Colors.grey[800]!,
                                          Colors.grey[900]!,
                                        ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected || isFound
                                ? [
                                    BoxShadow(
                                      color: isFound
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.blue.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currentGame.grid[row][col],
                            style: TextStyle(
                              color: isFound || isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.8),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoundWordsList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Bulunan Kelimeler: ${foundWords.length}/${currentGame.words.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (foundWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: foundWords.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.green.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      foundWords[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleGridTouch(Offset localPosition) {
    final gridPadding = 16.0;
    final gridWidth = MediaQuery.of(context).size.width - (gridPadding * 2);
    final cellSize = gridWidth / currentGame.gridSize;

    final x = localPosition.dx - gridPadding;
    final y = localPosition.dy - gridPadding;

    if (x >= 0 && x < gridWidth && y >= 0 && y < gridWidth) {
      final row = y ~/ cellSize;
      final col = x ~/ cellSize;
      if (row >= 0 &&
          row < currentGame.gridSize &&
          col >= 0 &&
          col < currentGame.gridSize) {
        _handleLetterSelection(row.toInt(), col.toInt());
      }
    }
  }
}
