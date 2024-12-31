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
  List<List<int>> hintPositions = [];

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

  // Oyunda kalan süre (saniye)
  int timeLeft = 30;

  // Oyunun başlayıp başlamadığını kontrol eden bayrak
  bool isGameStarted = false;

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

  // Oyun durumunu sıfırlayan metod
  void _resetGameState() {
    score = 0;
    foundWordsCount = 0;
    timeLeft = 30;
    foundWords = [];
    selectedWord = '';
    selectedPositions = [];
    hintPositions = [];
    selectedCells = List.generate(10, (i) => List.generate(10, (j) => false));
    foundCells = List.generate(10, (i) => List.generate(10, (j) => false));
  }

  // Kullanıcının hücre seçimlerini işleyen metod
  bool handleCellSelection(int row, int col) {
    // Oyun başlamadıysa veya hücre daha önce bulunmuşsa seçime izin verme
    if (!isGameStarted || foundCells[row][col]) return false;

    // Seçili hücreyi kaldırma işlemi
    if (selectedCells[row][col]) {
      int posIndex =
          selectedPositions.indexWhere((pos) => pos[0] == row && pos[1] == col);
      if (posIndex == selectedPositions.length - 1) {
        selectedCells[row][col] = false;
        selectedPositions.removeLast();
        _updateSelectedWord();
        return true;
      }
      return false;
    }

    // Yeni seçilen hücrenin son seçilen hücreye komşu olup olmadığını kontrol et
    if (selectedPositions.isNotEmpty) {
      List<int> lastPosition = selectedPositions.last;
      bool isAdjacent = (row - lastPosition[0]).abs() <= 1 &&
          (col - lastPosition[1]).abs() <= 1 &&
          !(row == lastPosition[0] && col == lastPosition[1]);

      if (!isAdjacent) return false;
    }

    // Yeni hücreyi seç
    selectedCells[row][col] = true;
    selectedPositions.add([row, col]);
    _updateSelectedWord();

    // Seçilen kelimeyi kontrol et
    if (targetWords.contains(selectedWord)) {
      _handleCorrectWord();
      return true;
    } else if (selectedWord.length >
        targetWords.map((w) => w.length).reduce(max)) {
      _handleWrongWord();
      return true;
    }

    return true;
  }

  // Seçili hücrelerden kelimeyi oluşturan metod
  void _updateSelectedWord() {
    selectedWord =
        selectedPositions.map((pos) => currentGrid[pos[0]][pos[1]]).join('');
  }

  // Doğru kelime bulunduğunda çağrılan metod
  void _handleCorrectWord() {
    score += 10;
    foundWordsCount++;
    foundWords.add(selectedWord);

    for (var pos in selectedPositions) {
      foundCells[pos[0]][pos[1]] = true;
    }

    clearSelection();
  }

  // Yanlış kelime seçildiğinde çağrılan metod
  void _handleWrongWord() {
    score = score - 10;
    clearSelection();
  }

  // Seçimleri temizleyen metod
  void clearSelection() {
    selectedCells = List.generate(10, (i) => List.generate(10, (j) => false));
    selectedWord = '';
    selectedPositions = [];
  }

  // İpucu veren metod
  void showHint() {
    if (!isGameStarted) return;

    // Henüz bulunmamış kelimelerden birini rastgele seç
    List<String> remainingWords =
        targetWords.where((word) => !foundWords.contains(word)).toList();
    if (remainingWords.isEmpty) return;

    String targetWord = remainingWords[Random().nextInt(remainingWords.length)];
    _findWordPosition(targetWord);
    score = score - 5; // İpucu kullanımı için puan cezası
  }

  // Verilen kelimenin tahtadaki konumunu bulan metod
  void _findWordPosition(String word) {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
        if (currentGrid[i][j] == word[0]) {
          // Kelimeyi yatay, dikey ve çapraz olarak ara
          if (_checkDirection(i, j, word, 0) || // yatay
              _checkDirection(i, j, word, 1) || // dikey
              _checkDirection(i, j, word, 2)) {
            // çapraz
            hintPositions.add([i, j]);
            clearSelection();
            selectedCells[i][j] = true;
            selectedPositions.add([i, j]);
            selectedWord = currentGrid[i][j];
            return;
          }
        }
      }
    }
  }

  // Verilen yönde kelimeyi kontrol eden metod
  bool _checkDirection(int startRow, int startCol, String word, int direction) {
    // Kelimenin tahtaya sığıp sığmadığını kontrol et
    if ((direction == 0 && startCol + word.length > 10) ||
        (direction == 1 && startRow + word.length > 10) ||
        (direction == 2 &&
            (startRow + word.length > 10 || startCol + word.length > 10))) {
      return false;
    }

    // Harfleri kontrol et
    for (int k = 0; k < word.length; k++) {
      int row = startRow + (direction == 0 ? 0 : k);
      int col = startCol + (direction == 1 ? 0 : k);
      if (currentGrid[row][col] != word[k]) return false;
    }
    return true;
  }

  // Oyun sonlandığında zamanlayıcıyı temizleyen metod
  void dispose() {
    timer?.cancel();
  }

  // Sadece kelimeleri ve gridi yeniler, puanı korur
  void refreshGame() {
    final random = Random();
    targetWords = List.from(_allWords)..shuffle(random);
    targetWords = targetWords.take(3).toList();

    foundWords.clear();
    selectedCells = List.generate(10, (i) => List.generate(10, (j) => false));
    foundCells = List.generate(10, (i) => List.generate(10, (j) => false));
    selectedWord = '';
    selectedPositions = [];
    hintPositions = [];
    foundWordsCount = 0;
    timeLeft = 30; // Süreyi sıfırla
    _generateRandomGrid();
  }
}
