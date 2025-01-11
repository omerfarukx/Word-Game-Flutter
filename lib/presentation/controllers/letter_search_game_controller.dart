import 'dart:async';
import 'dart:math';

class LetterSearchGameController {
  // Oyunda kullanılabilecek tüm kelimelerin listesi
  final List<String> _allWords = [
    'YARAMAZ',
    'KALEM',
    'OKUL',
    'KİTAP',
    'DEFTER',
    'SINIF',
    'ÖDEV',
    'MASA',
    'TAHTA',
    'SİLGİ',
    'ÖĞRETMEN',
    'ÖĞRENCİ',
    'OKUMA',
    'YAZMA',
    'SINAV',
    'BAŞARI',
    'ÇALIŞMA',
    'ÖĞRENME',
    'BİLGİ',
    'KÜTÜPHANE',
    'LABORATUVAR',
    'TENEFFÜS',
    'OYUN',
    'ARKADAŞ',
    'MÜDÜR',
    'DERS',
    'MATEMATİK',
    'FEN',
    'TARİH',
    'COĞRAFYA',
    'EDEBİYAT',
    'İNGİLİZCE',
    'SPOR',
    'MÜZİK',
    'RESİM',
    'PROJE',
    'SUNUM',
    'KARNE',
    'DİPLOMA',
    'MEZUN',
    'BAHÇE',
    'KANTİN',
    'YEMEKHANE',
    'SPOR SALONU',
    'KONFERANS',
    'TÖREN',
    'ETKİNLİK',
    'KULÜP',
    'YARIŞMA',
    'ÖDÜL',
    'SERTİFİKA',
    'BELGE',
    'SAAT',
    'DAKİKA',
    'SANİYE',
    'GÜN',
    'HAFTA',
    'AY',
    'YIL',
    'MEVSİM',
    'BAHAR',
    'YAZ',
    'SONBAHAR',
    'KIŞ',
    'SABAH',
    'ÖĞLE',
    'AKŞAM',
    'GECE',
    'BUGÜN',
    'YARIN',
    'DÜN',
    'AĞAÇ',
    'ÇİÇEK',
    'YAPRAK',
    'ORMAN',
    'DENİZ',
    'GÜNEŞ',
    'AY',
    'YILDIZ',
    'BULUT',
    'YAĞMUR',
    'KAR',
    'RÜZGAR',
    'TOPRAK',
    'DAĞLAR',
    'VADİ',
    'NEHİR',
    'GÖL',
    'OKYANUS',
    'ASLAN',
    'KAPLAN',
    'FİL',
    'ZÜRAFA',
    'MAYMUN',
    'KÖPEK',
    'KEDİ',
    'KUŞ',
    'BALIK',
    'TAVŞAN',
    'KURT',
    'AYI',
    'TİLKİ',
    'KARTAL',
    'PENGUEN',
    'YILAN',
    'KAPLUMBAĞA',
    'KIRMIZI',
    'MAVİ',
    'SARI',
    'YEŞİL',
    'MOR',
    'TURUNCU',
    'PEMBE',
    'SİYAH',
    'BEYAZ',
    'GRİ',
    'KAHVERENGİ',
    'LACİVERT',
    'ELMA',
    'ARMUT',
    'MUZ',
    'ÜZÜM',
    'KİRAZ',
    'ÇİLEK',
    'PORTAKAL',
    'MANDALİNA',
    'DOMATES',
    'SALATALIK',
    'PATATES',
    'HAVUÇ',
    'ISPANAK',
    'MARUL',
    'LAHANA',
    'ANNE',
    'BABA',
    'KARDEŞ',
    'ABLA',
    'AĞABEYİ',
    'DEDE',
    'NINE',
    'TEYZE',
    'HALA',
    'AMCA',
    'DAYILAR',
    'KUZEN',
    'AİLE',
    'AKRABA',
    'ÇOCUK',
    'BEBEK',
    'DOKTOR',
    'MÜHENDİS',
    'AVUKAT',
    'ÖĞRETMEN',
    'POLİS',
    'İTFAİYE',
    'AŞÇI',
    'ŞOFÖR',
    'PİLOT',
    'GARSON',
    'BERBER',
    'TERZ',
    'MİMAR',
    'RESSAM',
    'YAZILIMCI',
    'FUTBOL',
    'BASKETBOL',
    'VOLEYBOL',
    'TENİS',
    'YÜZME',
    'KOŞU',
    'BİSİKLET',
    'KAYAK',
    'BOKS',
    'GÜREŞ',
    'CİMNASTİK',
    'SATRANÇ',
    'MASA TENİSİ',
    'MUTLU',
    'ÜZGÜN',
    'KIZGIN',
    'ŞAŞKIN',
    'KORKU',
    'SEVGİ',
    'NEFRET',
    'HEYECAN',
    'MERAK',
    'UMUT',
    'ENDİŞE',
    'GURUR',
    'UTANÇ',
    'ÖZLEM'
  ];

  // Oyun için seçilen 3 hedef kelime
  List<String> targetWords = [];

  // 10x10'luk oyun tahtasını temsil eden matris
  List<List<String>> currentGrid = [];

  // Kullanıcının şu anda seçtiği hücreleri tutan matris (true/false)
  List<List<bool>> selectedCells = [];

  // Daha önce bulunmuş kelimelerin hücrelerini tutan matris (true/false)
  List<List<bool>> foundCells = [];

  // İpucu verilen hücrelerin konumlarını tutan liste [[satır, sütun],...]
  List<List<bool>> hintPositions = [];

  // Oyunda şimdiye kadar bulunmuş kelimelerin listesi
  List<String> foundWords = [];

  // Kullanıcının şu anda seçtiği harflerden oluşan kelime
  String selectedWord = '';

  // Kullanıcının seçtiği hücrelerin konumlarını tutan liste [[satır, sütun],...]
  List<List<int>> selectedPositions = [];

  // Oyuncunun mevcut puanı
  int score = 0;

  // Bulunan kelime sayısı
  int foundWordsCount = 0;

  // Mevcut bölüm
  int currentLevel = 1;

  // Oyunda kalan süre (saniye)
  int timeLeft = 60;

  // Bölüm başına azalacak süre
  static const int timeDecreasePerLevel = 5;

  // Minimum süre
  static const int minTime = 30;

  // Başlangıç süresi
  static const int maxTime = 60;

  // Oyunun başlayıp başlamadığını kontrol eden bayrak
  bool isGameStarted = false;

  // Kelime bulunduğunda ve yanlış seçim yapıldığında kullanılacak bayraklar
  bool isWordFound = false;
  bool isWrongSelection = false;

  // Süre sayacı için zamanlayıcı
  Timer? timer;

  // Oyunu başlatan ve ilk duruma getiren metod
  void initializeGame() {
    final random = Random();
    targetWords = List.from(_allWords)..shuffle(random);
    targetWords = targetWords.take(3).toList();

    _generateRandomGrid();
    _resetGameState();
  }

  // 10x10'luk oyun tahtasını oluşturan ve kelimeleri yerleştiren metod
  void _generateRandomGrid() {
    final random = Random();
    currentGrid = List.generate(10, (i) => List.generate(10, (j) => ''));
    // Türkçe alfabedeki büyük harfler (İ harfi için özel Unicode karakteri)
    const letters = 'ABCÇDEFGĞH\u0130JKLMNOÖPRSŞTUÜVYZ';

    // Hedef kelimeleri rastgele yönlerde (yatay, dikey, çapraz) yerleştir
    for (String word in targetWords) {
      bool placed = false;
      while (!placed) {
        int row = random.nextInt(10);
        int col = random.nextInt(10);
        int direction = random.nextInt(3); // 0: yatay, 1: dikey, 2: çapraz

        bool canPlace = true;
        List<List<int>> positions = [];

        // Kelimenin yerleştirilebilir olup olmadığını kontrol et
        for (int i = 0; i < word.length; i++) {
          int newRow = row;
          int newCol = col;

          switch (direction) {
            case 0:
              newCol = col + i;
              break; // yatay yerleştirme
            case 1:
              newRow = row + i;
              break; // dikey yerleştirme
            case 2:
              newRow = row + i;
              newCol = col + i;
              break; // çapraz yerleştirme
          }

          // Tahtanın sınırları içinde ve hücre boş mu kontrol et
          if (newRow >= 10 ||
              newCol >= 10 ||
              currentGrid[newRow][newCol].isNotEmpty) {
            canPlace = false;
            break;
          }
          positions.add([newRow, newCol]);
        }

        // Kelimeyi yerleştir
        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            currentGrid[positions[i][0]][positions[i][1]] = word[i];
          }
          placed = true;
        }
      }
    }

    // Boş kalan hücreleri rastgele harflerle doldur
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        if (currentGrid[i][j].isEmpty) {
          currentGrid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  // Oyun durumunu sıfırlayan yardımcı metod
  void _resetGameState() {
    selectedCells = List.generate(10, (_) => List.filled(10, false));
    foundCells = List.generate(10, (_) => List.filled(10, false));
    hintPositions = List.generate(10, (i) => List.generate(10, (j) => false));
    foundWords = [];
    selectedWord = '';
    selectedPositions = [];
    if (!isGameStarted) {
      score = 0;
      currentLevel = 1;
    }
    foundWordsCount = 0;
    // Bölüm başına süreyi azalt ama minimum sürenin altına düşme
    timeLeft =
        max(minTime, maxTime - ((currentLevel - 1) * timeDecreasePerLevel));
    isWordFound = false;
    isWrongSelection = false;
  }

  // Hücre seçimini işleyen metod
  bool handleCellSelection(int row, int col) {
    if (!isGameStarted) return false;

    isWordFound = false;
    isWrongSelection = false;

    if (selectedCells[row][col]) {
      // Seçili hücreyi kaldır
      selectedCells[row][col] = false;
      selectedPositions.removeWhere((pos) => pos[0] == row && pos[1] == col);
      _updateSelectedWord();
      return true;
    }

    // Yeni hücre seçimi
    selectedCells[row][col] = true;
    selectedPositions.add([row, col]);
    _updateSelectedWord();

    // Seçilen harflerden oluşabilecek tüm permütasyonları kontrol et
    bool wordFound = false;
    List<String> possibleWords = _generatePossibleWords();

    for (String word in possibleWords) {
      if (targetWords.contains(word)) {
        isWordFound = true;
        score += 10;
        foundWords.add(word);
        foundWordsCount++;
        timeLeft += 5; // Doğru kelime bulunduğunda 5 saniye ekle

        // Bulunan kelimenin hücrelerini işaretle
        for (var pos in selectedPositions) {
          foundCells[pos[0]][pos[1]] = true;
        }

        clearSelection();
        wordFound = true;
        break;
      }
    }

    if (!wordFound) {
      // En uzun hedef kelimenin uzunluğunu bul
      int maxWordLength = targetWords.map((word) => word.length).reduce(max);
      if (selectedWord.length >= maxWordLength) {
        isWrongSelection = true;
        clearSelection();
      }
    }

    return true;
  }

  // Seçili harflerden oluşabilecek tüm olası kelimeleri üreten yardımcı metod
  List<String> _generatePossibleWords() {
    // Sadece seçilen harflerin sırasıyla oluşan kelimeyi kontrol et
    return [selectedWord];
  }

  // Seçili kelimeyi güncelleyen yardımcı metod
  void _updateSelectedWord() {
    selectedWord =
        selectedPositions.map((pos) => currentGrid[pos[0]][pos[1]]).join('');
  }

  // İpucu gösteren metod
  void showHint() {
    if (!isGameStarted) return;

    // Puanı düşür
    score = max(0, score - 5);

    // İpucu pozisyonlarını ve seçili hücreleri temizle
    hintPositions = List.generate(10, (i) => List.generate(10, (j) => false));
    clearSelection();

    // Henüz bulunmamış kelimelerden birini seç
    List<String> remainingWords =
        targetWords.where((word) => !foundWords.contains(word)).toList();
    if (remainingWords.isEmpty) return;

    final random = Random();
    final targetWord = remainingWords[random.nextInt(remainingWords.length)];

    // Kelimeyi tahtada bul ve ipucu göster
    bool found = false;
    for (int i = 0; i < 10 && !found; i++) {
      for (int j = 0; j < 10 && !found; j++) {
        if (currentGrid[i][j] == targetWord[0]) {
          // Tüm yönleri kontrol et
          for (int direction = 0; direction < 8 && !found; direction++) {
            if (_checkWordInDirection(i, j, targetWord, direction)) {
              _highlightWordInDirection(i, j, targetWord.length, direction);
              // İpucu gösterilen harfleri seçili hale getir
              _selectWordInDirection(i, j, targetWord.length, direction);
              found = true;
            }
          }
        }
      }
    }
  }

  // Verilen yönde kelimeyi kontrol eden yardımcı metod
  bool _checkWordInDirection(
      int startRow, int startCol, String word, int direction) {
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

    // Kelimenin sınırlar içinde olup olmadığını kontrol et
    int endRow = startRow + dRow * (word.length - 1);
    int endCol = startCol + dCol * (word.length - 1);

    if (endRow < 0 || endRow >= 10 || endCol < 0 || endCol >= 10) {
      return false;
    }

    // Kelimeyi kontrol et
    for (int i = 0; i < word.length; i++) {
      int row = startRow + dRow * i;
      int col = startCol + dCol * i;
      if (currentGrid[row][col] != word[i]) {
        return false;
      }
    }
    return true;
  }

  // Kelimeyi belirtilen yönde vurgula
  void _highlightWordInDirection(
      int startRow, int startCol, int length, int direction) {
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
      hintPositions[row][col] = true;
    }
  }

  // Seçimi temizleyen metod
  void clearSelection() {
    selectedCells = List.generate(10, (_) => List.filled(10, false));
    selectedPositions = [];
    selectedWord = '';
  }

  // Kelimeyi belirtilen yönde seç
  void _selectWordInDirection(
      int startRow, int startCol, int length, int direction) {
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
      selectedCells[row][col] = true;
      selectedPositions.add([row, col]);
    }
    _updateSelectedWord();
  }

  void dispose() {
    timer?.cancel();
  }

  // Oyunu yenileyen metod
  void refreshGame() {
    final currentScore = score;
    final level = currentLevel + 1;
    initializeGame();
    score = currentScore;
    currentLevel = level;
  }
}
