/// Curated semantic relations for Kelime Odağı. The 49k dictionary has no
/// relations, so these are hand-authored and quality-checked. Distractors are
/// pulled live from the dictionary, not stored here.
enum FocusType { synonym, antonym, family, category }

extension FocusTypeX on FocusType {
  String get label => switch (this) {
        FocusType.synonym => 'Eş Anlamlı',
        FocusType.antonym => 'Zıt Anlamlı',
        FocusType.family => 'Kelime Ailesi',
        FocusType.category => 'Kategori',
      };

  String get blurb => switch (this) {
        FocusType.synonym => 'Aynı anlama gelen kelimeleri seç',
        FocusType.antonym => 'Zıt anlamlı kelimeleri seç',
        FocusType.family => 'Aynı kökten türeyenleri seç',
        FocusType.category => 'Kategoriye ait olanları seç',
      };

  /// Centre-word prompt, e.g. "MUTLU ile aynı anlama gelenleri seç".
  String prompt(String center) => switch (this) {
        FocusType.synonym => '$center ile aynı anlama gelenler',
        FocusType.antonym => '$center kelimesinin zıttı',
        FocusType.family => '$center kökünden türeyenler',
        FocusType.category => '$center kategorisindekiler',
      };
}

class FocusEntry {
  const FocusEntry(this.center, this.matches);
  final String center;
  final List<String> matches;
}

class WordFocusData {
  const WordFocusData._();

  static const Map<FocusType, List<FocusEntry>> entries = {
    FocusType.synonym: [
      FocusEntry('mutlu', ['neşeli', 'sevinçli', 'memnun']),
      FocusEntry('güzel', ['hoş', 'şirin', 'latif']),
      FocusEntry('hızlı', ['çabuk', 'seri', 'ivedi']),
      FocusEntry('akıllı', ['zeki', 'anlayışlı', 'kavrayışlı']),
      FocusEntry('cesur', ['yürekli', 'yiğit', 'korkusuz']),
      FocusEntry('zor', ['çetin', 'güç', 'müşkül']),
      FocusEntry('büyük', ['iri', 'kocaman', 'ulu']),
      FocusEntry('yardım', ['destek', 'katkı', 'takviye']),
      FocusEntry('gerçek', ['hakiki', 'sahici', 'doğru']),
      FocusEntry('ünlü', ['tanınmış', 'meşhur', 'namlı']),
      FocusEntry('zengin', ['varlıklı', 'paralı']),
      FocusEntry('yavaş', ['ağır', 'sakin']),
      FocusEntry('kirli', ['pis', 'murdar']),
      FocusEntry('konuk', ['misafir', 'davetli']),
    ],
    FocusType.antonym: [
      FocusEntry('sıcak', ['soğuk']),
      FocusEntry('büyük', ['küçük']),
      FocusEntry('hızlı', ['yavaş']),
      FocusEntry('açık', ['kapalı']),
      FocusEntry('iyi', ['kötü']),
      FocusEntry('uzun', ['kısa']),
      FocusEntry('güzel', ['çirkin']),
      FocusEntry('doğru', ['yanlış']),
      FocusEntry('ileri', ['geri']),
      FocusEntry('zengin', ['fakir', 'yoksul']),
      FocusEntry('mutlu', ['üzgün']),
      FocusEntry('aydınlık', ['karanlık']),
      FocusEntry('genç', ['yaşlı']),
      FocusEntry('dolu', ['boş']),
    ],
    FocusType.family: [
      FocusEntry('göz', ['gözlük', 'gözlem', 'gözcü']),
      FocusEntry('yol', ['yolcu', 'yolculuk', 'yolsuz']),
      FocusEntry('su', ['sulu', 'susuz', 'sulama']),
      FocusEntry('ev', ['evli', 'evcil', 'evsiz']),
      FocusEntry('baş', ['başkan', 'başarı', 'başlık']),
      FocusEntry('kitap', ['kitaplık', 'kitapçı']),
      FocusEntry('iş', ['işçi', 'işsiz', 'işlem']),
      FocusEntry('bil', ['bilgi', 'bilim', 'bilgin']),
      FocusEntry('yaz', ['yazar', 'yazı', 'yazılı']),
      FocusEntry('gör', ['görüş', 'görgü', 'görüntü']),
      FocusEntry('ses', ['sesli', 'sessiz']),
      FocusEntry('tuz', ['tuzlu', 'tuzsuz', 'tuzluk']),
    ],
    FocusType.category: [
      FocusEntry('meyve', ['elma', 'armut', 'kiraz', 'muz']),
      FocusEntry('hayvan', ['kedi', 'köpek', 'aslan', 'kuş']),
      FocusEntry('renk', ['kırmızı', 'mavi', 'yeşil', 'sarı']),
      FocusEntry('meslek', ['doktor', 'öğretmen', 'mühendis']),
      FocusEntry('sebze', ['domates', 'biber', 'patates']),
      FocusEntry('spor', ['futbol', 'basketbol', 'tenis']),
      FocusEntry('çalgı', ['keman', 'gitar', 'piyano']),
      FocusEntry('mevsim', ['yaz', 'kış', 'sonbahar']),
      FocusEntry('vücut', ['kol', 'bacak', 'parmak']),
      FocusEntry('giysi', ['gömlek', 'pantolon', 'ceket']),
      FocusEntry('mutfak', ['tabak', 'kaşık', 'tencere']),
      FocusEntry('taşıt', ['otobüs', 'tren', 'vapur']),
    ],
  };
}
