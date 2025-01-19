import 'dart:async';

class WordChainGame {
  String currentWord = '';
  List<String> usedWords = [];
  int score = 0;
  int timeLeft = 90; // 90 saniyelik oyun
  Timer? _timer;
  bool isGameActive = false;
  String? errorMessage;
  int combo = 0;
  int maxCombo = 0;
  int longestWord = 0;

  // Oyun durumu için stream controller
  final _gameStateController = StreamController<WordChainGameState>.broadcast();
  Stream<WordChainGameState> get gameState => _gameStateController.stream;

  void startGame() {
    isGameActive = true;
    score = 0;
    usedWords.clear();
    timeLeft = 90;
    combo = 0;
    maxCombo = 0;
    longestWord = 0;
    errorMessage = null;
    currentWord = '';
    _startTimer();
    _updateGameState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;
      if (timeLeft <= 0) {
        endGame();
      }
      _updateGameState();
    });
  }

  bool isValidWord(String word) {
    word = word.trim().toLowerCase();

    // Boş kelime kontrolü
    if (word.isEmpty) {
      errorMessage = 'Lütfen bir kelime girin';
      return false;
    }

    // Minimum uzunluk kontrolü
    if (word.length < 2) {
      errorMessage = 'Kelime en az 2 harf olmalıdır';
      return false;
    }

    // Daha önce kullanılmış kelime kontrolü
    if (usedWords.contains(word)) {
      errorMessage = 'Bu kelime daha önce kullanıldı';
      return false;
    }

    // İlk kelime veya son harf kontrolü
    if (currentWord.isNotEmpty) {
      String lastChar = currentWord[currentWord.length - 1].toLowerCase();
      if (!word.startsWith(lastChar)) {
        errorMessage =
            'Kelime "${lastChar.toUpperCase()}" harfi ile başlamalıdır';
        return false;
      }
    }

    errorMessage = null;
    return true;
  }

  void submitWord(String word) {
    if (!isGameActive) return;

    if (isValidWord(word)) {
      currentWord = word;
      usedWords.add(word);

      // Puan hesaplama
      int wordScore = word.length * 10; // Her harf 10 puan

      // Combo sistemi
      combo++;
      if (combo > maxCombo) maxCombo = combo;

      if (combo >= 3) {
        wordScore = (wordScore * 1.5).round(); // 3+ combo için %50 bonus
      }

      // En uzun kelime takibi
      if (word.length > longestWord) {
        longestWord = word.length;
      }

      score += wordScore;
      _updateGameState();
    } else {
      combo = 0; // Hatalı kelimede combo sıfırlanır
      _updateGameState();
    }
  }

  void endGame() {
    isGameActive = false;
    _timer?.cancel();
    _updateGameState();
  }

  void _updateGameState() {
    _gameStateController.add(
      WordChainGameState(
        currentWord: currentWord,
        usedWords: List.from(usedWords),
        score: score,
        timeLeft: timeLeft,
        isGameActive: isGameActive,
        errorMessage: errorMessage,
        combo: combo,
        maxCombo: maxCombo,
        longestWord: longestWord,
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
    _gameStateController.close();
  }
}

class WordChainGameState {
  final String currentWord;
  final List<String> usedWords;
  final int score;
  final int timeLeft;
  final bool isGameActive;
  final String? errorMessage;
  final int combo;
  final int maxCombo;
  final int longestWord;

  WordChainGameState({
    required this.currentWord,
    required this.usedWords,
    required this.score,
    required this.timeLeft,
    required this.isGameActive,
    this.errorMessage,
    required this.combo,
    required this.maxCombo,
    required this.longestWord,
  });
}
