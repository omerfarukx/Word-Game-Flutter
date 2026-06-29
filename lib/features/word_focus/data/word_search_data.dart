/// Themed word banks for Kelime Bulma. Each puzzle draws one theme so the
/// grid feels coherent ("Hayvanlar", "Meyveler", …). Words are kept short
/// enough to fit a 9x9 grid.
class WordSearchTheme {
  const WordSearchTheme(this.name, this.words);
  final String name;
  final List<String> words;
}

class WordSearchData {
  const WordSearchData._();

  static const List<WordSearchTheme> themes = [
    WordSearchTheme('Hayvanlar',
        ['kedi', 'köpek', 'aslan', 'kaplan', 'tilki', 'kurt', 'geyik', 'tavşan']),
    WordSearchTheme('Meyveler',
        ['elma', 'armut', 'kiraz', 'muz', 'incir', 'üzüm', 'kavun', 'erik']),
    WordSearchTheme('Renkler',
        ['kırmızı', 'mavi', 'yeşil', 'sarı', 'mor', 'pembe', 'siyah', 'beyaz']),
    WordSearchTheme('Meslekler',
        ['doktor', 'hemşire', 'pilot', 'aşçı', 'terzi', 'polis', 'asker', 'ressam']),
    WordSearchTheme('Sebzeler',
        ['domates', 'biber', 'patates', 'soğan', 'havuç', 'marul', 'turp', 'kabak']),
    WordSearchTheme('Vücut',
        ['kol', 'bacak', 'parmak', 'göz', 'kulak', 'burun', 'ağız', 'omuz']),
    WordSearchTheme('Doğa',
        ['deniz', 'orman', 'dağ', 'nehir', 'göl', 'çöl', 'ada', 'vadi']),
    WordSearchTheme('Mutfak',
        ['tabak', 'kaşık', 'çatal', 'bıçak', 'tencere', 'tava', 'bardak', 'kova']),
    WordSearchTheme('Okul',
        ['kalem', 'defter', 'kitap', 'silgi', 'cetvel', 'çanta', 'tahta', 'sıra']),
    WordSearchTheme('Spor',
        ['futbol', 'tenis', 'boks', 'kayak', 'yüzme', 'koşu', 'güreş', 'okçuluk']),
    WordSearchTheme('Çalgılar',
        ['keman', 'gitar', 'piyano', 'davul', 'flüt', 'saz', 'ney', 'org']),
    WordSearchTheme('Taşıtlar',
        ['otobüs', 'tren', 'vapur', 'uçak', 'bisiklet', 'kamyon', 'metro', 'tekne']),
  ];
}
