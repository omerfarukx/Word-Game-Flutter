import 'dart:math';

enum WordCategory {
  meyveler,
  hayvanlar,
  sehirler,
  ulkeler,
  meslekler,
  renkler,
  sporlar,
  tasitlar,
  mobilyalar,
  sebzeler,
  kiyafetler,
  okul,
  doga,
  aile,
  teknoloji
}

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
  late int maxWordLength;

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
        isCompleted = false {
    // En uzun kelimenin uzunluğunu bul
    maxWordLength =
        words.fold(0, (max, word) => word.length > max ? word.length : max);
  }

  factory WordSearchGame.easy() {
    switch (WordCategory.values[Random().nextInt(WordCategory.values.length)]) {
      case WordCategory.meyveler:
        return WordSearchGame(
          words: [
            'ELMA',
            'ARMUT',
            'KİRAZ',
            'ÜZÜM',
            'İNCİR',
            'PORTAKAL',
            'MUZ',
            'KARPUZ'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.meyveler,
          hints: [
            'Kırmızı veya yeşil olabilir',
            'Armut gibi armut',
            'Mayıs ayının meyvesi',
            'Salkım salkım',
            'Ege\'nin meşhur meyvesi',
            'C vitamini deposu',
            'Potasyum kaynağı',
            'Yazın vazgeçilmezi'
          ],
        );
      case WordCategory.hayvanlar:
        return WordSearchGame(
          words: [
            'ASLAN',
            'KAPLAN',
            'ZEBRA',
            'FİL',
            'ZÜRAFA',
            'PENGUEN',
            'PANDA',
            'AYI'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.hayvanlar,
          hints: [
            'Ormanlar kralı',
            'Çizgili kedi',
            'Siyah beyaz çizgili',
            'Uzun hortumlu',
            'Uzun boyunlu',
            'Kutupların sakini',
            'Bambu sever',
            'Kış uykusuna yatar'
          ],
        );
      case WordCategory.sehirler:
        return WordSearchGame(
          words: [
            'ANKARA',
            'İSTANBUL',
            'İZMİR',
            'BURSA',
            'ANTALYA',
            'ADANA',
            'MERSİN',
            'MUĞLA'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.sehirler,
          hints: [
            'Başkent',
            'Boğaz şehri',
            'Ege\'nin incisi',
            'Yeşil Bursa',
            'Turizm başkenti',
            'Kebap şehri',
            'Narenciye diyarı',
            'Bodrum\'un ili'
          ],
        );
      case WordCategory.ulkeler:
        return WordSearchGame(
          words: [
            'TÜRKİYE',
            'ALMANYA',
            'FRANSA',
            'İTALYA',
            'JAPONYA',
            'KANADA',
            'BREZİLYA',
            'MISIR'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.ulkeler,
          hints: [
            'Ay yıldızlı bayrak',
            'Avrupa\'nın motoru',
            'Eyfel\'in ülkesi',
            'Pizza ve makarna',
            'Güneşin doğduğu yer',
            'Akçaağaç yaprağı',
            'Samba ülkesi',
            'Piramitlerin vatanı'
          ],
        );
      case WordCategory.meslekler:
        return WordSearchGame(
          words: [
            'DOKTOR',
            'AVUKAT',
            'ÖĞRETMEN',
            'MÜHENDİS',
            'AŞÇI',
            'PİLOT',
            'BERBER',
            'MİMAR'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.meslekler,
          hints: [
            'Sağlık çalışanı',
            'Hukuk adamı',
            'Eğitimci',
            'Teknik uzman',
            'Mutfağın şefi',
            'Göklerin kaptanı',
            'Saç ve sakal ustası',
            'Yapı tasarımcısı'
          ],
        );
      case WordCategory.renkler:
        return WordSearchGame(
          words: [
            'KIRMIZI',
            'MAVİ',
            'YEŞİL',
            'SARI',
            'MOR',
            'TURUNCU',
            'PEMBE',
            'SİYAH'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.renkler,
          hints: [
            'Aşkın rengi',
            'Denizin rengi',
            'Doğanın rengi',
            'Güneşin rengi',
            'Asaletin rengi',
            'Portakalın rengi',
            'Pamuk şekerin rengi',
            'Gecenin rengi'
          ],
        );
      case WordCategory.sporlar:
        return WordSearchGame(
          words: [
            'FUTBOL',
            'BASKETBOL',
            'VOLEYBOL',
            'TENİS',
            'YÜZME',
            'BOKS',
            'GÜREŞ',
            'KAYAK'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.sporlar,
          hints: [
            'En popüler spor',
            'Potaya atış',
            'File üstü oyun',
            'Raketli spor',
            'Su sporu',
            'Yumruk sporu',
            'Ata sporu',
            'Kış sporu'
          ],
        );
      case WordCategory.tasitlar:
        return WordSearchGame(
          words: [
            'ARABA',
            'UÇAK',
            'TREN',
            'GEMİ',
            'OTOBÜS',
            'METRO',
            'BİSİKLET',
            'MOTOR'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.tasitlar,
          hints: [
            'Dört tekerlekli',
            'Göklerin taşıtı',
            'Raylı sistem',
            'Deniz taşıtı',
            'Toplu taşıma',
            'Yeraltı treni',
            'İki tekerlekli',
            'İki tekerlekli motorlu'
          ],
        );
      case WordCategory.mobilyalar:
        return WordSearchGame(
          words: [
            'MASA',
            'KOLTUK',
            'DOLAP',
            'YATAK',
            'SANDALYE',
            'KİTAPLIK',
            'KANEPE',
            'BÜFE'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.mobilyalar,
          hints: [
            'Üzerinde yemek yeriz',
            'Oturma odası klasiği',
            'Eşya saklama ünitesi',
            'Uyku mobilyası',
            'Tek kişilik oturma',
            'Kitap rafları',
            'Uzanmalık mobilya',
            'Yemek odası mobilyası'
          ],
        );
      case WordCategory.sebzeler:
        return WordSearchGame(
          words: [
            'DOMATES',
            'BİBER',
            'PATLICAN',
            'HAVUÇ',
            'PATATES',
            'ISPANAK',
            'MARUL',
            'KABAK'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.sebzeler,
          hints: [
            'Salçanın hammaddesi',
            'Acı veya tatlı olur',
            'Karnıyarık malzemesi',
            'Tavşanın sevdiği',
            'Kızartması meşhur',
            'Demir deposu sebze',
            'Yeşil yapraklı',
            'Hem tatlısı hem yemeği'
          ],
        );
      case WordCategory.kiyafetler:
        return WordSearchGame(
          words: [
            'GÖMLEK',
            'PANTOLON',
            'CEKET',
            'KAZAK',
            'ELBİSE',
            'ETEK',
            'ŞORT',
            'MONT'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.kiyafetler,
          hints: [
            'Yakalı üst giysi',
            'Bacakları örter',
            'Takım elbise parçası',
            'Yün örme giysi',
            'Kadın tek parça',
            'Diz üstü giysi',
            'Yaz mevsimi giysisi',
            'Kışlık dış giyim'
          ],
        );
      case WordCategory.okul:
        return WordSearchGame(
          words: [
            'KALEM',
            'DEFTER',
            'KİTAP',
            'SİLGİ',
            'ÇANTA',
            'CETVEL',
            'PERGEL',
            'BOYA'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.okul,
          hints: [
            'Yazı yazma aracı',
            'Not tutma aracı',
            'Okuma materyali',
            'Hata düzeltici',
            'Eşya taşıyıcı',
            'Çizgi çekme aracı',
            'Daire çizme aracı',
            'Resim yapma malzemesi'
          ],
        );
      case WordCategory.doga:
        return WordSearchGame(
          words: [
            'AĞAÇ',
            'ÇİÇEK',
            'ORMAN',
            'DENİZ',
            'DAĞLAR',
            'BULUT',
            'GÜNEŞ',
            'YILDIZ'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.doga,
          hints: [
            'Gölge veren',
            'Bahçe süsü',
            'Ağaç topluluğu',
            'Tuzlu su kütlesi',
            'Yüksek yerler',
            'Gökyüzü süsü',
            'Isı kaynağı',
            'Gece parlayan'
          ],
        );
      case WordCategory.aile:
        return WordSearchGame(
          words: [
            'ANNE',
            'BABA',
            'KARDEŞ',
            'DEDE',
            'NINE',
            'TEYZE',
            'AMCA',
            'DAYI'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.aile,
          hints: [
            'Ailenin kadını',
            'Ailenin erkeği',
            'Aynı anne babadan',
            'Babanın babası',
            'Annenin annesi',
            'Annenin kız kardeşi',
            'Babanın erkek kardeşi',
            'Annenin erkek kardeşi'
          ],
        );
      case WordCategory.teknoloji:
        return WordSearchGame(
          words: [
            'TELEFON',
            'BİLGİSAYAR',
            'TABLET',
            'ROBOT',
            'DRONE',
            'YAZICI',
            'MODEM',
            'KAMERA'
          ],
          gridSize: 8,
          timeLeft: 180,
          category: WordCategory.teknoloji,
          hints: [
            'İletişim cihazı',
            'Masaüstü cihaz',
            'Taşınabilir ekran',
            'Yapay zeka ürünü',
            'Uzaktan kontrol',
            'Baskı makinesi',
            'İnternet cihazı',
            'Görüntü kaydedici'
          ],
        );
    }
  }

  void generateGrid() {
    int maxGridAttempts = 5; // Maksimum grid oluşturma denemesi
    bool success = false;

    while (maxGridAttempts > 0 && !success) {
      success = true;
      final random = Random();
      validMoves.clear();

      // Grid'i temizle
      for (var i = 0; i < gridSize; i++) {
        for (var j = 0; j < gridSize; j++) {
          grid[i][j] = '';
        }
      }

      // Kelimeleri gride yerleştir
      for (final word in words) {
        bool placed = false;
        int attempts = 0;
        while (!placed && attempts < 100) {
          attempts++;

          // Yatay, dikey veya çapraz yerleştirme
          final direction = random.nextInt(3); // 0: yatay, 1: dikey, 2: çapraz
          int maxRow, maxCol;

          switch (direction) {
            case 0: // yatay
              maxRow = gridSize;
              maxCol = gridSize - word.length + 1;
              break;
            case 1: // dikey
              maxRow = gridSize - word.length + 1;
              maxCol = gridSize;
              break;
            case 2: // çapraz
              maxRow = gridSize - word.length + 1;
              maxCol = gridSize - word.length + 1;
              break;
            default:
              maxRow = gridSize;
              maxCol = gridSize;
          }

          // Eğer kelime grid'e sığmıyorsa, yeni yön dene
          if (maxRow <= 0 || maxCol <= 0) {
            continue;
          }

          // Rastgele pozisyon seç
          final row = random.nextInt(maxRow);
          final col = random.nextInt(maxCol);

          // Kelimeyi yerleştirmeyi dene
          if (canPlaceWord(word, row, col, direction)) {
            placeWord(word, row, col, direction);
            placed = true;
          }
        }

        if (!placed) {
          success = false;
          maxGridAttempts--;
          break;
        }
      }

      if (success) {
        // Boş kalan yerleri rastgele harflerle doldur
        fillEmptySpaces();
      }
    }

    // Eğer grid oluşturulamadıysa, basit bir grid oluştur
    if (!success) {
      createSimpleGrid();
    }
  }

  void createSimpleGrid() {
    validMoves.clear();
    // Grid'i temizle
    for (var i = 0; i < gridSize; i++) {
      for (var j = 0; j < gridSize; j++) {
        grid[i][j] = '';
      }
    }

    // Kelimeleri sadece yatay olarak yerleştir
    int currentRow = 0;
    for (final word in words) {
      if (currentRow < gridSize && word.length <= gridSize) {
        for (int i = 0; i < word.length; i++) {
          grid[currentRow][i] = word[i];
        }
        validMoves.add(List.generate(word.length * 2,
            (index) => index % 2 == 0 ? currentRow : index ~/ 2));
        currentRow++;
      }
    }

    // Boş kalan yerleri doldur
    fillEmptySpaces();
  }

  bool canPlaceWord(String word, int row, int col, int direction) {
    if (row < 0 || col < 0 || row >= gridSize || col >= gridSize) return false;

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

      // Sınırları kontrol et
      if (currentRow >= gridSize || currentCol >= gridSize) return false;

      // Çakışma kontrolü
      if (grid[currentRow][currentCol].isNotEmpty &&
          grid[currentRow][currentCol] != word[i]) return false;

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
