import 'dart:math';

enum WordCategory { fruits, animals, cities, countries, professions }

class WordSearchGame {
  final List<String> words;
  final List<List<String>> grid;
  final int gridSize;
  final WordCategory category;
  final List<String> hints;
  int hintsLeft;
  int score;
  int timeLeft;
  bool isCompleted;
  List<List<int>> validMoves = [];

  WordSearchGame({
    required this.words,
    required this.gridSize,
    required this.timeLeft,
    required this.category,
    required this.hints,
    this.hintsLeft = 3,
  })  : grid = List.generate(
          gridSize,
          (_) => List.generate(gridSize, (_) => ''),
        ),
        score = 0,
        isCompleted = false;

  factory WordSearchGame.easy() {
    return WordSearchGame(
      words: ['ELMA', 'ARMUT', 'KİRAZ', 'ÜZÜM', 'İNCİR'],
      gridSize: 8,
      timeLeft: 180,
      category: WordCategory.fruits,
      hints: [
        'Kırmızı veya yeşil olabilir',
        'Armut gibi armut',
        'Mayıs ayının meyvesi',
        'Salkım salkım',
        'Ege\'nin meşhur meyvesi'
      ],
    );
  }

  factory WordSearchGame.medium() {
    return WordSearchGame(
      words: ['ASLAN', 'KAPLAN', 'ZEBRA', 'FİL', 'ZÜRAFA'],
      gridSize: 10,
      timeLeft: 240,
      category: WordCategory.animals,
      hints: [
        'Ormanlar kralı',
        'Çizgili kedi',
        'Siyah beyaz çizgili',
        'Uzun hortumlu',
        'Uzun boyunlu'
      ],
    );
  }

  factory WordSearchGame.hard() {
    return WordSearchGame(
      words: ['İSTANBUL', 'ANKARA', 'İZMİR', 'BURSA', 'ANTALYA'],
      gridSize: 12,
      timeLeft: 300,
      category: WordCategory.cities,
      hints: [
        'Boğaz şehri',
        'Başkent',
        'Ege\'nin incisi',
        'Yeşil Bursa',
        'Turizm başkenti'
      ],
    );
  }

  void generateGrid() {
    final random = Random();
    validMoves.clear();

    // Kelimeleri gride yerleştir
    for (final word in words) {
      bool placed = false;
      while (!placed) {
        // Yatay, dikey veya çapraz yerleştirme
        final direction = random.nextInt(3); // 0: yatay, 1: dikey, 2: çapraz
        int maxRow, maxCol;

        switch (direction) {
          case 0: // yatay
            maxRow = gridSize;
            maxCol = gridSize - word.length;
            break;
          case 1: // dikey
            maxRow = gridSize - word.length;
            maxCol = gridSize;
            break;
          case 2: // çapraz
            maxRow = gridSize - word.length;
            maxCol = gridSize - word.length;
            break;
          default:
            maxRow = gridSize;
            maxCol = gridSize;
        }

        final row = random.nextInt(maxRow);
        final col = random.nextInt(maxCol);

        if (canPlaceWord(word, row, col, direction)) {
          placeWord(word, row, col, direction);
          placed = true;
        }
      }
    }

    // Boş kalan yerleri rastgele harflerle doldur
    fillEmptySpaces();
  }

  bool canPlaceWord(String word, int row, int col, int direction) {
    List<List<int>> positions = [];

    for (int i = 0; i < word.length; i++) {
      int currentRow = row;
      int currentCol = col;

      switch (direction) {
        case 0: // yatay
          currentCol = col + i;
          break;
        case 1: // dikey
          currentRow = row + i;
          break;
        case 2: // çapraz
          currentRow = row + i;
          currentCol = col + i;
          break;
      }

      if (currentRow >= gridSize || currentCol >= gridSize) return false;
      if (grid[currentRow][currentCol].isNotEmpty) return false;

      positions.add([currentRow, currentCol]);
    }

    validMoves.add(positions.expand((pos) => pos).toList());
    return true;
  }

  void placeWord(String word, int row, int col, int direction) {
    for (int i = 0; i < word.length; i++) {
      switch (direction) {
        case 0: // yatay
          grid[row][col + i] = word[i];
          break;
        case 1: // dikey
          grid[row + i][col] = word[i];
          break;
        case 2: // çapraz
          grid[row + i][col + i] = word[i];
          break;
      }
    }
  }

  void fillEmptySpaces() {
    const turkishLetters = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';
    final random = Random();

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].isEmpty) {
          grid[i][j] = turkishLetters[random.nextInt(turkishLetters.length)];
        }
      }
    }
  }

  bool isValidSelection(List<int> positions) {
    if (positions.length < 4)
      return true; // En az 2 harf seçilebilir (satır ve sütun için 4 pozisyon)

    // Seçilen harflerin sıralı olup olmadığını kontrol et
    int row1 = positions[positions.length - 4];
    int col1 = positions[positions.length - 3];
    int row2 = positions[positions.length - 2];
    int col2 = positions[positions.length - 1];

    // Yatay kontrol
    if (row1 == row2 && (col2 == col1 + 1 || col2 == col1 - 1)) return true;

    // Dikey kontrol
    if (col1 == col2 && (row2 == row1 + 1 || row2 == row1 - 1)) return true;

    // Çapraz kontrol
    if ((row2 == row1 + 1 && col2 == col1 + 1) || // Sağ alt çapraz
        (row2 == row1 - 1 && col2 == col1 - 1) || // Sol üst çapraz
        (row2 == row1 + 1 && col2 == col1 - 1) || // Sol alt çapraz
        (row2 == row1 - 1 && col2 == col1 + 1)) // Sağ üst çapraz
      return true;

    return false;
  }

  String getWordFromPositions(List<int> positions) {
    String word = '';
    for (int i = 0; i < positions.length; i += 2) {
      word += grid[positions[i]][positions[i + 1]];
    }
    return word;
  }

  bool checkWord(String word) {
    return words.contains(word);
  }

  String? useHint() {
    if (hintsLeft > 0) {
      hintsLeft--;
      return hints[Random().nextInt(hints.length)];
    }
    return null;
  }

  void updateScore(String word) {
    score += word.length * 10;
  }

  void updateTime() {
    if (timeLeft > 0) timeLeft--;
    if (timeLeft == 0) isCompleted = true;
  }
}

bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
