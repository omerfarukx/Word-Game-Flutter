import 'dart:async';
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

class _WordSearchWidgetState extends State<WordSearchWidget> {
  Timer? _timer;
  List<String> foundWords = [];
  List<int> selectedIndices = [];
  bool isDragging = false;
  late WordSearchGame currentGame;

  @override
  void initState() {
    super.initState();
    currentGame = widget.game;
    startNewGame();
  }

  void startNewGame() {
    setState(() {
      foundWords.clear();
      selectedIndices.clear();
      currentGame = WordSearchGame.easy();
      currentGame.generateGrid();
      _timer?.cancel();
      startTimer();
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
        title: const Text('Oyun Bitti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puanınız: ${currentGame.score}'),
            Text(
                'Bulunan Kelimeler: ${foundWords.length}/${currentGame.words.length}'),
            const SizedBox(height: 8),
            Text('Bulunamayan Kelimeler:'),
            ...currentGame.words
                .where((word) => !foundWords.contains(word))
                .map((word) => Text('- $word')),
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
          TextButton(
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleLetterSelection(int row, int col) {
    final index = row * currentGame.gridSize + col;

    setState(() {
      if (!isDragging) {
        // Tek tıklama ile seçim
        if (selectedIndices.contains(index)) {
          selectedIndices.clear();
        } else {
          if (selectedIndices.isEmpty) {
            selectedIndices.add(index);
          } else {
            // Pozisyonları kontrol et
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

              // Seçilen harflerden kelime oluştur
              String selectedWord = '';
              for (int idx in selectedIndices) {
                int r = idx ~/ currentGame.gridSize;
                int c = idx % currentGame.gridSize;
                selectedWord += currentGame.grid[r][c];
              }

              // Kelimeyi kontrol et
              if (currentGame.checkWord(selectedWord) &&
                  !foundWords.contains(selectedWord)) {
                foundWords.add(selectedWord);
                currentGame.updateScore(selectedWord);
                selectedIndices.clear();
              }
            }
          }
        }
      } else {
        // Sürükleme ile seçim
        if (!selectedIndices.contains(index)) {
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

            // Seçilen harflerden kelime oluştur
            String selectedWord = '';
            for (int idx in selectedIndices) {
              int r = idx ~/ currentGame.gridSize;
              int c = idx % currentGame.gridSize;
              selectedWord += currentGame.grid[r][c];
            }

            // Kelimeyi kontrol et
            if (currentGame.checkWord(selectedWord) &&
                !foundWords.contains(selectedWord)) {
              foundWords.add(selectedWord);
              currentGame.updateScore(selectedWord);
              selectedIndices.clear();
            }
          }
        }
      }
    });
  }

  void _showHint() {
    final hint = currentGame.useHint();
    if (hint != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İpucu: $hint'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İpucu hakkınız kalmadı!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            // Üst bilgi paneli
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Puan
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.purple, size: 20),
                        Text(
                          ' ${currentGame.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Süre
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.orange, size: 20),
                        Text(
                          ' ${currentGame.timeLeft}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // İpucu butonu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.lightbulb_outline,
                          color: Colors.blue),
                      onPressed: _showHint,
                      tooltip: 'İpucu (${currentGame.hintsLeft} hak)',
                    ),
                  ),
                ],
              ),
            ),

            // Kategori bilgisi
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Kategori: ${currentGame.category.name.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Kelime gridi
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);
                    isDragging = true;
                    _handleGridTouch(localPosition);
                  },
                  onPanUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);
                    _handleGridTouch(localPosition);
                  },
                  onPanEnd: (details) {
                    setState(() {
                      isDragging = false;
                      selectedIndices.clear();
                    });
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: currentGame.gridSize,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: currentGame.gridSize * currentGame.gridSize,
                    itemBuilder: (context, index) {
                      final row = index ~/ currentGame.gridSize;
                      final col = index % currentGame.gridSize;
                      final isSelected = selectedIndices.contains(index);

                      return GestureDetector(
                        onTapDown: (_) => _handleLetterSelection(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue.shade300
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            currentGame.grid[row][col],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade300,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bulunan kelimeler listesi
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
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
                              color: Colors.green.shade800,
                              borderRadius: BorderRadius.circular(20),
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
            ),
          ],
        ),
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
