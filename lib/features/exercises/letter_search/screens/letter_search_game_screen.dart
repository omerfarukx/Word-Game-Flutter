import 'package:flutter/material.dart';
import 'dart:math' as math;

class LetterSearchGameScreen extends StatefulWidget {
  const LetterSearchGameScreen({super.key});

  @override
  State<LetterSearchGameScreen> createState() => _LetterSearchGameScreenState();
}

class _LetterSearchGameScreenState extends State<LetterSearchGameScreen> {
  final List<String> targetWords = ['SINAV', 'ÖDÜL', 'GÖZLEM'];
  final int gridSize = 10;
  late List<List<String>> letterGrid;
  List<List<bool>> selectedCells = [];
  List<String> foundWords = [];
  List<Offset> currentSelection = [];
  String currentWord = '';
  Map<String, List<Offset>> foundWordPositions = {};
  Offset? startPosition;
  Offset? endPosition;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    letterGrid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => _getRandomLetter(),
      ),
    );

    selectedCells = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => false),
    );

    _placeWords();
  }

  String _getRandomLetter() {
    const letters = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';
    return letters[math.Random().nextInt(letters.length)];
  }

  void _placeWords() {
    for (String word in targetWords) {
      bool placed = false;
      int maxAttempts = 100;
      int attempts = 0;

      while (!placed && attempts < maxAttempts) {
        attempts++;
        int row = math.Random().nextInt(gridSize);
        int col = math.Random().nextInt(gridSize);

        List<List<int>> directions = [
          [-1, -1],
          [-1, 0],
          [-1, 1],
          [0, -1],
          [0, 1],
          [1, -1],
          [1, 0],
          [1, 1]
        ];

        directions.shuffle();

        for (List<int> dir in directions) {
          int rowDir = dir[0];
          int colDir = dir[1];

          if (_canPlaceWord(word, row, col, rowDir, colDir)) {
            for (int i = 0; i < word.length; i++) {
              letterGrid[row + (i * rowDir)][col + (i * colDir)] = word[i];
            }
            placed = true;
            break;
          }
        }
      }
    }
  }

  bool _canPlaceWord(
      String word, int startRow, int startCol, int rowDir, int colDir) {
    for (int i = 0; i < word.length; i++) {
      int newRow = startRow + (i * rowDir);
      int newCol = startCol + (i * colDir);

      if (newRow < 0 ||
          newRow >= gridSize ||
          newCol < 0 ||
          newCol >= gridSize) {
        return false;
      }
    }
    return true;
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final cellWidth = constraints.maxWidth / gridSize;
    final cellHeight = constraints.maxHeight / gridSize;

    final row = (localPosition.dy / cellHeight).floor();
    final col = (localPosition.dx / cellWidth).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() {
        startPosition = Offset(col.toDouble(), row.toDouble());
        endPosition = startPosition;
        currentWord = letterGrid[row][col];
      });
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (startPosition == null) return;

    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    final cellWidth = constraints.maxWidth / gridSize;
    final cellHeight = constraints.maxHeight / gridSize;

    final row = (localPosition.dy / cellHeight).floor();
    final col = (localPosition.dx / cellWidth).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() {
        endPosition = Offset(col.toDouble(), row.toDouble());
        _updateCurrentWord();
      });
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (startPosition != null && endPosition != null) {
      if (targetWords.contains(currentWord) &&
          !foundWords.contains(currentWord)) {
        setState(() {
          foundWords.add(currentWord);
          foundWordPositions[currentWord] = [startPosition!, endPosition!];
        });
      }
    }
    setState(() {
      startPosition = null;
      endPosition = null;
      currentWord = '';
    });
  }

  void _updateCurrentWord() {
    if (startPosition == null || endPosition == null) return;

    String word = '';
    final dx = endPosition!.dx - startPosition!.dx;
    final dy = endPosition!.dy - startPosition!.dy;
    final steps = math.max(dx.abs(), dy.abs()).toInt();

    if (steps == 0) {
      word = letterGrid[startPosition!.dy.toInt()][startPosition!.dx.toInt()];
    } else {
      final stepX = dx / steps;
      final stepY = dy / steps;

      for (int i = 0; i <= steps; i++) {
        final x = startPosition!.dx + (stepX * i);
        final y = startPosition!.dy + (stepY * i);
        word += letterGrid[y.round()][x.round()];
      }
    }

    currentWord = word;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harf Arama Oyunu'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bulunacak Kelimeler:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: targetWords.map((word) {
                        final isFound = foundWords.contains(word);
                        return Chip(
                          label: Text(
                            word,
                            style: TextStyle(
                              decoration:
                                  isFound ? TextDecoration.lineThrough : null,
                              color: isFound ? Colors.grey : Colors.black,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onPanStart: (details) =>
                        _handlePanStart(details, constraints),
                    onPanUpdate: (details) =>
                        _handlePanUpdate(details, constraints),
                    onPanEnd: _handlePanEnd,
                    child: CustomPaint(
                      painter: WordSearchPainter(
                        gridSize: gridSize,
                        startPosition: startPosition,
                        endPosition: endPosition,
                        foundWordPositions: foundWordPositions,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (context, index) {
                          final row = index ~/ gridSize;
                          final col = index % gridSize;
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              letterGrid[row][col],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Puan: ${foundWords.length}/${targetWords.length}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WordSearchPainter extends CustomPainter {
  final int gridSize;
  final Offset? startPosition;
  final Offset? endPosition;
  final Map<String, List<Offset>> foundWordPositions;

  WordSearchPainter({
    required this.gridSize,
    this.startPosition,
    this.endPosition,
    required this.foundWordPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Geçerli seçimi çiz
    if (startPosition != null && endPosition != null) {
      final cellWidth = size.width / gridSize;
      final cellHeight = size.height / gridSize;

      canvas.drawLine(
        Offset(
          (startPosition!.dx + 0.5) * cellWidth,
          (startPosition!.dy + 0.5) * cellHeight,
        ),
        Offset(
          (endPosition!.dx + 0.5) * cellWidth,
          (endPosition!.dy + 0.5) * cellHeight,
        ),
        paint,
      );
    }

    // Bulunan kelimeleri çiz
    paint.color = Colors.green.withOpacity(0.5);
    for (var positions in foundWordPositions.values) {
      if (positions.length == 2) {
        final cellWidth = size.width / gridSize;
        final cellHeight = size.height / gridSize;

        canvas.drawLine(
          Offset(
            (positions[0].dx + 0.5) * cellWidth,
            (positions[0].dy + 0.5) * cellHeight,
          ),
          Offset(
            (positions[1].dx + 0.5) * cellWidth,
            (positions[1].dy + 0.5) * cellHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WordSearchPainter oldDelegate) {
    return startPosition != oldDelegate.startPosition ||
        endPosition != oldDelegate.endPosition ||
        foundWordPositions != oldDelegate.foundWordPositions;
  }
}
