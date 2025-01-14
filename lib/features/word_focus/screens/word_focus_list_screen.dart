import 'package:flutter/material.dart';
import '../models/word_focus_game.dart';
import '../models/word_pair.dart';
import 'word_focus_screen.dart';

class WordFocusListScreen extends StatelessWidget {
  const WordFocusListScreen({Key? key}) : super(key: key);

  // Test için örnek kelime çiftleri
  WordPair _getTestWordPair(WordGameType type) {
    switch (type) {
      case WordGameType.synonyms:
        final wordPairs = [
          const WordPair(
            mainWord: 'güzel',
            relatedWords: [
              'hoş',
              'çirkin',
              'iyi',
              'kötü',
              'muhteşem',
              'harika',
              'berbat',
              'müthiş'
            ],
            correctWords: ['hoş', 'muhteşem', 'harika', 'müthiş'],
          ),
          const WordPair(
            mainWord: 'cesur',
            relatedWords: [
              'korkak',
              'yiğit',
              'kahraman',
              'ürkek',
              'gözüpek',
              'korkusuz',
              'çekingen',
              'mert'
            ],
            correctWords: ['yiğit', 'kahraman', 'gözüpek', 'korkusuz', 'mert'],
          ),
          const WordPair(
            mainWord: 'hızlı',
            relatedWords: [
              'yavaş',
              'çevik',
              'süratli',
              'ağır',
              'tembel',
              'çabuk',
              'atik',
              'yavaşça'
            ],
            correctWords: ['çevik', 'süratli', 'çabuk', 'atik'],
          ),
          const WordPair(
            mainWord: 'akıllı',
            relatedWords: [
              'zeki',
              'aptal',
              'bilge',
              'cahil',
              'anlayışlı',
              'kavrayışlı',
              'budala',
              'dahi'
            ],
            correctWords: ['zeki', 'bilge', 'anlayışlı', 'kavrayışlı', 'dahi'],
          ),
          const WordPair(
            mainWord: 'mutlu',
            relatedWords: [
              'üzgün',
              'neşeli',
              'sevinçli',
              'kederli',
              'keyifli',
              'mesut',
              'mutsuz',
              'şen'
            ],
            correctWords: ['neşeli', 'sevinçli', 'keyifli', 'mesut', 'şen'],
          ),
          const WordPair(
            mainWord: 'zengin',
            relatedWords: [
              'fakir',
              'varlıklı',
              'yoksul',
              'varsıl',
              'paralı',
              'görgülü',
              'parasız',
              'bolluk'
            ],
            correctWords: ['varlıklı', 'varsıl', 'paralı', 'görgülü'],
          ),
          const WordPair(
            mainWord: 'doğru',
            relatedWords: [
              'yanlış',
              'gerçek',
              'hakiki',
              'sahte',
              'düzgün',
              'dürüst',
              'yalan',
              'hatalı'
            ],
            correctWords: ['gerçek', 'hakiki', 'düzgün', 'dürüst'],
          ),
          const WordPair(
            mainWord: 'temiz',
            relatedWords: [
              'kirli',
              'pak',
              'pis',
              'arı',
              'saf',
              'lekesiz',
              'pasaklı',
              'berrak'
            ],
            correctWords: ['pak', 'arı', 'saf', 'lekesiz', 'berrak'],
          ),
          const WordPair(
            mainWord: 'büyük',
            relatedWords: [
              'küçük',
              'kocaman',
              'ufak',
              'iri',
              'dev',
              'muazzam',
              'minik',
              'azıcık'
            ],
            correctWords: ['kocaman', 'iri', 'dev', 'muazzam'],
          ),
          const WordPair(
            mainWord: 'yeni',
            relatedWords: [
              'eski',
              'taze',
              'köhne',
              'modern',
              'çağdaş',
              'güncel',
              'kadim',
              'bayat'
            ],
            correctWords: ['taze', 'modern', 'çağdaş', 'güncel'],
          ),
        ];

        // Rastgele bir kelime çifti seç
        return wordPairs[
            DateTime.now().millisecondsSinceEpoch % wordPairs.length];

      case WordGameType.antonyms:
        final wordPairs = [
          const WordPair(
            mainWord: 'sıcak',
            relatedWords: [
              'soğuk',
              'ılık',
              'serin',
              'kaynar',
              'buz',
              'donuk',
              'ateş',
              'buzlu'
            ],
            correctWords: ['soğuk', 'buz', 'buzlu'],
          ),
          const WordPair(
            mainWord: 'büyük',
            relatedWords: [
              'küçük',
              'ufak',
              'minik',
              'dev',
              'kocaman',
              'minimal',
              'iri',
              'minnacık'
            ],
            correctWords: ['küçük', 'ufak', 'minik', 'minnacık'],
          ),
          const WordPair(
            mainWord: 'hızlı',
            relatedWords: [
              'yavaş',
              'süratli',
              'ağır',
              'çevik',
              'atik',
              'aheste',
              'çabuk',
              'yavaşça'
            ],
            correctWords: ['yavaş', 'ağır', 'aheste', 'yavaşça'],
          ),
          const WordPair(
            mainWord: 'güzel',
            relatedWords: [
              'çirkin',
              'hoş',
              'kötü',
              'muhteşem',
              'berbat',
              'harika',
              'iğrenç',
              'müthiş'
            ],
            correctWords: ['çirkin', 'kötü', 'berbat', 'iğrenç'],
          ),
          const WordPair(
            mainWord: 'zengin',
            relatedWords: [
              'fakir',
              'varlıklı',
              'yoksul',
              'varsıl',
              'parasız',
              'paralı',
              'züğürt',
              'muhtaç'
            ],
            correctWords: ['fakir', 'yoksul', 'parasız', 'züğürt', 'muhtaç'],
          ),
          const WordPair(
            mainWord: 'akıllı',
            relatedWords: [
              'aptal',
              'zeki',
              'budala',
              'bilge',
              'salak',
              'dahi',
              'ahmak',
              'anlayışlı'
            ],
            correctWords: ['aptal', 'budala', 'salak', 'ahmak'],
          ),
          const WordPair(
            mainWord: 'uzun',
            relatedWords: [
              'kısa',
              'upuzun',
              'bodur',
              'yüksek',
              'cüce',
              'boylu',
              'alçak',
              'ufak'
            ],
            correctWords: ['kısa', 'bodur', 'cüce', 'alçak'],
          ),
          const WordPair(
            mainWord: 'açık',
            relatedWords: [
              'kapalı',
              'aydınlık',
              'örtülü',
              'net',
              'gizli',
              'şeffaf',
              'saklı',
              'berrak'
            ],
            correctWords: ['kapalı', 'örtülü', 'gizli', 'saklı'],
          ),
          const WordPair(
            mainWord: 'tatlı',
            relatedWords: [
              'acı',
              'şekerli',
              'ekşi',
              'lezzetli',
              'buruk',
              'ballı',
              'mayhoş',
              'tuzlu'
            ],
            correctWords: ['acı', 'ekşi', 'buruk', 'tuzlu'],
          ),
          const WordPair(
            mainWord: 'dolu',
            relatedWords: [
              'boş',
              'tıklım',
              'eksik',
              'tam',
              'yarım',
              'ağzına',
              'noksan',
              'tıka'
            ],
            correctWords: ['boş', 'eksik', 'yarım', 'noksan'],
          ),
          const WordPair(
            mainWord: 'kalın',
            relatedWords: [
              'ince',
              'yoğun',
              'narin',
              'şişman',
              'zayıf',
              'dar',
              'sıska',
              'geniş'
            ],
            correctWords: ['ince', 'narin', 'zayıf', 'sıska'],
          ),
          const WordPair(
            mainWord: 'sert',
            relatedWords: [
              'yumuşak',
              'katı',
              'gevşek',
              'sağlam',
              'esnek',
              'güçlü',
              'yumşak',
              'hafif'
            ],
            correctWords: ['yumuşak', 'gevşek', 'esnek', 'yumşak'],
          ),
          const WordPair(
            mainWord: 'kolay',
            relatedWords: [
              'zor',
              'basit',
              'güç',
              'rahat',
              'karmaşık',
              'pratik',
              'çetin',
              'zahmetli'
            ],
            correctWords: ['zor', 'güç', 'karmaşık', 'çetin', 'zahmetli'],
          ),
          const WordPair(
            mainWord: 'temiz',
            relatedWords: [
              'kirli',
              'pak',
              'pis',
              'arı',
              'pasaklı',
              'lekesiz',
              'bakımsız',
              'berrak'
            ],
            correctWords: ['kirli', 'pis', 'pasaklı', 'bakımsız'],
          ),
          const WordPair(
            mainWord: 'yaşlı',
            relatedWords: [
              'genç',
              'ihtiyar',
              'delikanlı',
              'kocamış',
              'toy',
              'tecrübeli',
              'körpe',
              'taze'
            ],
            correctWords: ['genç', 'delikanlı', 'toy', 'körpe', 'taze'],
          ),
        ];

        // Rastgele bir kelime çifti seç
        return wordPairs[
            DateTime.now().millisecondsSinceEpoch % wordPairs.length];

      case WordGameType.wordFamily:
        final wordPairs = [
          const WordPair(
            mainWord: 'göz',
            relatedWords: [
              'gözlük',
              'gözcü',
              'görmek',
              'bakmak',
              'gözlem',
              'gözetmek',
              'izlemek',
              'seyretmek'
            ],
            correctWords: ['gözlük', 'gözcü', 'gözlem', 'gözetmek'],
          ),
          const WordPair(
            mainWord: 'yol',
            relatedWords: [
              'yolcu',
              'yolculuk',
              'gitmek',
              'yolluk',
              'yoldaş',
              'araba',
              'yollamak',
              'otobüs'
            ],
            correctWords: ['yolcu', 'yolculuk', 'yolluk', 'yollamak'],
          ),
          const WordPair(
            mainWord: 'baş',
            relatedWords: [
              'başkan',
              'başlık',
              'kafa',
              'başlamak',
              'başarı',
              'beyin',
              'başvuru',
              'saç'
            ],
            correctWords: ['başkan', 'başlık', 'başlamak', 'başvuru'],
          ),
          const WordPair(
            mainWord: 'su',
            relatedWords: [
              'sucu',
              'sulu',
              'içmek',
              'suluk',
              'sulamak',
              'deniz',
              'susuz',
              'bardak'
            ],
            correctWords: ['sucu', 'sulu', 'suluk', 'sulamak', 'susuz'],
          ),
          const WordPair(
            mainWord: 'ev',
            relatedWords: [
              'evli',
              'evcilik',
              'bina',
              'evlenmek',
              'evsel',
              'apartman',
              'evcil',
              'site'
            ],
            correctWords: ['evli', 'evcilik', 'evlenmek', 'evsel', 'evcil'],
          ),
          const WordPair(
            mainWord: 'iş',
            relatedWords: [
              'işçi',
              'işlik',
              'çalışmak',
              'işlemek',
              'işsiz',
              'para',
              'işveren',
              'maaş'
            ],
            correctWords: ['işçi', 'işlik', 'işlemek', 'işsiz', 'işveren'],
          ),
          const WordPair(
            mainWord: 'dil',
            relatedWords: [
              'dilci',
              'dilbilgisi',
              'konuşmak',
              'dilsiz',
              'dilli',
              'ağız',
              'dilekçe',
              'söz'
            ],
            correctWords: ['dilci', 'dilbilgisi', 'dilsiz', 'dilli', 'dilekçe'],
          ),
          const WordPair(
            mainWord: 'baş',
            relatedWords: [
              'başlangıç',
              'başarılı',
              'kafa',
              'başkent',
              'başrol',
              'beyin',
              'başhekim',
              'saç'
            ],
            correctWords: [
              'başlangıç',
              'başarılı',
              'başkent',
              'başrol',
              'başhekim'
            ],
          ),
          const WordPair(
            mainWord: 'el',
            relatedWords: [
              'ellik',
              'elci',
              'tutmak',
              'eldiven',
              'elden',
              'parmak',
              'ellemek',
              'kol'
            ],
            correctWords: ['ellik', 'elci', 'eldiven', 'elden', 'ellemek'],
          ),
          const WordPair(
            mainWord: 'göz',
            relatedWords: [
              'gözlükçü',
              'gözcülük',
              'bakmak',
              'gözlemci',
              'gözleme',
              'görüş',
              'gözetim',
              'lens'
            ],
            correctWords: [
              'gözlükçü',
              'gözcülük',
              'gözlemci',
              'gözleme',
              'gözetim'
            ],
          ),
          const WordPair(
            mainWord: 'kitap',
            relatedWords: [
              'kitapçı',
              'kitaplık',
              'okumak',
              'kitapçık',
              'kitabi',
              'sayfa',
              'kitapevi',
              'dergi'
            ],
            correctWords: [
              'kitapçı',
              'kitaplık',
              'kitapçık',
              'kitabi',
              'kitapevi'
            ],
          ),
          const WordPair(
            mainWord: 'deniz',
            relatedWords: [
              'denizci',
              'denizlik',
              'yüzmek',
              'denizaltı',
              'denizel',
              'dalga',
              'denizcilik',
              'balık'
            ],
            correctWords: [
              'denizci',
              'denizlik',
              'denizaltı',
              'denizel',
              'denizcilik'
            ],
          ),
          const WordPair(
            mainWord: 'yağ',
            relatedWords: [
              'yağlı',
              'yağmur',
              'akmak',
              'yağdanlık',
              'yağsız',
              'zeytinyağı',
              'yağlamak',
              'tereyağı'
            ],
            correctWords: [
              'yağlı',
              'yağmur',
              'yağdanlık',
              'yağsız',
              'yağlamak'
            ],
          ),
          const WordPair(
            mainWord: 'balık',
            relatedWords: [
              'balıkçı',
              'balıklı',
              'yüzmek',
              'balıkçılık',
              'balıkhane',
              'deniz',
              'balıketi',
              'olta'
            ],
            correctWords: [
              'balıkçı',
              'balıklı',
              'balıkçılık',
              'balıkhane',
              'balıketi'
            ],
          ),
          const WordPair(
            mainWord: 'taş',
            relatedWords: [
              'taşçı',
              'taşlık',
              'atmak',
              'taşlamak',
              'taşlı',
              'kaya',
              'taşımak',
              'çakıl'
            ],
            correctWords: ['taşçı', 'taşlık', 'taşlamak', 'taşlı', 'taşımak'],
          ),
          const WordPair(
            mainWord: 'dağ',
            relatedWords: [
              'dağcı',
              'dağlık',
              'tırmanmak',
              'dağcılık',
              'dağlı',
              'tepe',
              'dağılmak',
              'yayla'
            ],
            correctWords: ['dağcı', 'dağlık', 'dağcılık', 'dağlı', 'dağılmak'],
          ),
          const WordPair(
            mainWord: 'çiçek',
            relatedWords: [
              'çiçekçi',
              'çiçeklik',
              'açmak',
              'çiçekçilik',
              'çiçeksi',
              'gül',
              'çiçeklenmek',
              'bahçe'
            ],
            correctWords: [
              'çiçekçi',
              'çiçeklik',
              'çiçekçilik',
              'çiçeksi',
              'çiçeklenmek'
            ],
          ),
          const WordPair(
            mainWord: 'yazı',
            relatedWords: [
              'yazıcı',
              'yazılı',
              'okumak',
              'yazılım',
              'yazısız',
              'kalem',
              'yazıhane',
              'defter'
            ],
            correctWords: [
              'yazıcı',
              'yazılı',
              'yazılım',
              'yazısız',
              'yazıhane'
            ],
          ),
          const WordPair(
            mainWord: 'ses',
            relatedWords: [
              'sesli',
              'sesçi',
              'duymak',
              'sessiz',
              'sesleniş',
              'müzik',
              'seslenmek',
              'gürültü'
            ],
            correctWords: ['sesli', 'sesçi', 'sessiz', 'sesleniş', 'seslenmek'],
          ),
          const WordPair(
            mainWord: 'renk',
            relatedWords: [
              'renkli',
              'renksiz',
              'boyamak',
              'renkçi',
              'renklendirmek',
              'boya',
              'renklilik',
              'palette'
            ],
            correctWords: [
              'renkli',
              'renksiz',
              'renkçi',
              'renklendirmek',
              'renklilik'
            ],
          ),
          const WordPair(
            mainWord: 'oyun',
            relatedWords: [
              'oyuncu',
              'oyuncak',
              'oynamak',
              'oyunculuk',
              'oyunsuz',
              'sahne',
              'oyunbaz',
              'eğlence'
            ],
            correctWords: [
              'oyuncu',
              'oyuncak',
              'oyunculuk',
              'oyunsuz',
              'oyunbaz'
            ],
          ),
        ];

        // Rastgele bir kelime çifti seç
        return wordPairs[
            DateTime.now().millisecondsSinceEpoch % wordPairs.length];
      case WordGameType.category:
        final wordPairs = [
          const WordPair(
            mainWord: 'elma',
            relatedWords: [
              'armut',
              'masa',
              'kiraz',
              'sandalye',
              'muz',
              'dolap',
              'portakal',
              'koltuk'
            ],
            correctWords: ['armut', 'kiraz', 'muz', 'portakal'],
            category: 'Meyveler',
          ),
          const WordPair(
            mainWord: 'aslan',
            relatedWords: [
              'kaplan',
              'ağaç',
              'fil',
              'çiçek',
              'zürafa',
              'yaprak',
              'leopar',
              'dal'
            ],
            correctWords: ['kaplan', 'fil', 'zürafa', 'leopar'],
            category: 'Hayvanlar',
          ),
          const WordPair(
            mainWord: 'gömlek',
            relatedWords: [
              'pantolon',
              'kitap',
              'ceket',
              'kalem',
              'elbise',
              'defter',
              'kazak',
              'silgi'
            ],
            correctWords: ['pantolon', 'ceket', 'elbise', 'kazak'],
            category: 'Kıyafetler',
          ),
          const WordPair(
            mainWord: 'masa',
            relatedWords: [
              'sandalye',
              'elma',
              'dolap',
              'armut',
              'koltuk',
              'muz',
              'yatak',
              'kiraz'
            ],
            correctWords: ['sandalye', 'dolap', 'koltuk', 'yatak'],
            category: 'Mobilyalar',
          ),
          const WordPair(
            mainWord: 'domates',
            relatedWords: [
              'biber',
              'kalem',
              'patlıcan',
              'silgi',
              'havuç',
              'defter',
              'patates',
              'kitap'
            ],
            correctWords: ['biber', 'patlıcan', 'havuç', 'patates'],
            category: 'Sebzeler',
          ),
          const WordPair(
            mainWord: 'kalem',
            relatedWords: [
              'silgi',
              'masa',
              'defter',
              'sandalye',
              'kitap',
              'dolap',
              'cetvel',
              'koltuk'
            ],
            correctWords: ['silgi', 'defter', 'kitap', 'cetvel'],
            category: 'Kırtasiye',
          ),
          const WordPair(
            mainWord: 'futbol',
            relatedWords: [
              'basketbol',
              'elma',
              'voleybol',
              'armut',
              'tenis',
              'muz',
              'hentbol',
              'kiraz'
            ],
            correctWords: ['basketbol', 'voleybol', 'tenis', 'hentbol'],
            category: 'Sporlar',
          ),
          const WordPair(
            mainWord: 'kırmızı',
            relatedWords: [
              'mavi',
              'aslan',
              'yeşil',
              'kaplan',
              'sarı',
              'fil',
              'mor',
              'zürafa'
            ],
            correctWords: ['mavi', 'yeşil', 'sarı', 'mor'],
            category: 'Renkler',
          ),
          const WordPair(
            mainWord: 'İstanbul',
            relatedWords: [
              'Ankara',
              'gömlek',
              'İzmir',
              'pantolon',
              'Bursa',
              'ceket',
              'Antalya',
              'elbise'
            ],
            correctWords: ['Ankara', 'İzmir', 'Bursa', 'Antalya'],
            category: 'Şehirler',
          ),
          const WordPair(
            mainWord: 'Türkiye',
            relatedWords: [
              'Almanya',
              'masa',
              'Fransa',
              'sandalye',
              'İtalya',
              'dolap',
              'İspanya',
              'koltuk'
            ],
            correctWords: ['Almanya', 'Fransa', 'İtalya', 'İspanya'],
            category: 'Ülkeler',
          ),
          const WordPair(
            mainWord: 'piyano',
            relatedWords: [
              'gitar',
              'domates',
              'keman',
              'biber',
              'flüt',
              'patlıcan',
              'davul',
              'havuç'
            ],
            correctWords: ['gitar', 'keman', 'flüt', 'davul'],
            category: 'Müzik Aletleri',
          ),
          const WordPair(
            mainWord: 'öğretmen',
            relatedWords: [
              'doktor',
              'kalem',
              'mühendis',
              'silgi',
              'avukat',
              'defter',
              'hemşire',
              'kitap'
            ],
            correctWords: ['doktor', 'mühendis', 'avukat', 'hemşire'],
            category: 'Meslekler',
          ),
          const WordPair(
            mainWord: 'ocak',
            relatedWords: [
              'şubat',
              'futbol',
              'mart',
              'basketbol',
              'nisan',
              'voleybol',
              'mayıs',
              'tenis'
            ],
            correctWords: ['şubat', 'mart', 'nisan', 'mayıs'],
            category: 'Aylar',
          ),
          const WordPair(
            mainWord: 'pazartesi',
            relatedWords: [
              'salı',
              'kırmızı',
              'çarşamba',
              'mavi',
              'perşembe',
              'yeşil',
              'cuma',
              'sarı'
            ],
            correctWords: ['salı', 'çarşamba', 'perşembe', 'cuma'],
            category: 'Günler',
          ),
          const WordPair(
            mainWord: 'buzdolabı',
            relatedWords: [
              'fırın',
              'İstanbul',
              'çamaşır',
              'Ankara',
              'bulaşık',
              'İzmir',
              'mikrodalga',
              'Bursa'
            ],
            correctWords: ['fırın', 'çamaşır', 'bulaşık', 'mikrodalga'],
            category: 'Beyaz Eşyalar',
          ),
        ];

        // Rastgele bir kelime çifti seç
        return wordPairs[
            DateTime.now().millisecondsSinceEpoch % wordPairs.length];
    }
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required WordFocusGame game,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordFocusScreen(
                game: game,
                wordPair: _getTestWordPair(game.type),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Kelime Odağı Oyunları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildGameCard(
            context,
            title: 'Eş Anlamlılar',
            description: 'Kelimelerin eş anlamlılarını bulun',
            color: Colors.green,
            icon: Icons.sync_alt,
            game: WordFocusGame.synonyms(
              id: 'synonyms_1',
              difficultyLevel: 1,
            ),
          ),
          _buildGameCard(
            context,
            title: 'Zıt Anlamlılar',
            description: 'Kelimelerin zıt anlamlılarını bulun',
            color: Colors.orange,
            icon: Icons.compare_arrows,
            game: WordFocusGame.antonyms(
              id: 'antonyms_1',
              difficultyLevel: 1,
            ),
          ),
          _buildGameCard(
            context,
            title: 'Kelime Ailesi',
            description: 'Aynı kökten türeyen kelimeleri bulun',
            color: Colors.purple,
            icon: Icons.account_tree,
            game: WordFocusGame.wordFamily(
              id: 'word_family_1',
              difficultyLevel: 1,
            ),
          ),
          _buildGameCard(
            context,
            title: 'Kategori Eşleştirme',
            description: 'Aynı kategorideki kelimeleri bulun',
            color: Colors.blue,
            icon: Icons.category,
            game: WordFocusGame.category(
              id: 'category_1',
              difficultyLevel: 1,
            ),
          ),
        ],
      ),
    );
  }
}
