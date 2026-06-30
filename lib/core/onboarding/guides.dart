import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/route_constants.dart';
import '../design/app_colors.dart';

/// A short "how to play" for one game: a title, an icon, an accent and a few
/// plain-language steps. Kept in one place so the home screen and any in-game
/// help button show the exact same guidance.
class GameGuide {
  const GameGuide({
    required this.title,
    required this.icon,
    required this.accent,
    required this.steps,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> steps;
}

/// Per-game guides keyed by route, plus persisted "already seen" flags so the
/// first time you open a game its rules pop up once, and never nag after.
class Guides {
  Guides._();
  static final Guides instance = Guides._();

  final Set<String> _seen = {};
  bool _onboarded = false;
  SharedPreferences? _prefs;

  static const _seenKey = 'guide_seen';
  static const _onboardedKey = 'app_onboarded';

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _seen.addAll(_prefs!.getStringList(_seenKey) ?? const []);
      _onboarded = _prefs!.getBool(_onboardedKey) ?? false;
    } catch (_) {}
  }

  bool get onboarded => _onboarded;
  void setOnboarded() {
    _onboarded = true;
    _prefs?.setBool(_onboardedKey, true);
  }

  bool isSeen(String route) => _seen.contains(route);
  void markSeen(String route) {
    if (_seen.add(route)) _prefs?.setStringList(_seenKey, _seen.toList());
  }

  GameGuide? forRoute(String route) => _guides[route];

  static const Map<String, GameGuide> _guides = {
    RouteConstants.wordPairs: GameGuide(
      title: 'Kelime Çiftleri',
      icon: Icons.compare_arrows_rounded,
      accent: AppColors.word,
      steps: [
        'Her kart üst üste iki kelime gösterir.',
        'Çoğu kart aynı; bazılarında tek harf farklıdır.',
        'Farklı olan kartlara dokun, hepsini bul.',
        'Yanlış dokunma süre kaybettirir.',
      ],
    ),
    RouteConstants.wordRecognition: GameGuide(
      title: 'Kelime Tanıma',
      icon: Icons.flash_on_rounded,
      accent: AppColors.word,
      steps: [
        'Ekranda bir kelime kısa süre yanıp söner.',
        'Gördüğün kelimeyi aklında tut.',
        'Ardından aynı kelimeyi yaz.',
        'İlerledikçe gösterim süresi kısalır.',
      ],
    ),
    RouteConstants.wordFocus: GameGuide(
      title: 'Kelime Odağı',
      icon: Icons.hub_rounded,
      accent: AppColors.word,
      steps: [
        'Bir ilişki türü seç (eş/zıt anlam, aile, kategori).',
        'Ortadaki kelimeyle ilişkili olanlara dokun.',
        'Çeldirici (ilgisiz) kelimelere dokunma.',
        'Doğru seçimler kombo ve puan kazandırır.',
      ],
    ),
    RouteConstants.wordSearch: GameGuide(
      title: 'Kelime Bulma',
      icon: Icons.grid_on_rounded,
      accent: AppColors.word,
      steps: [
        'Aşağıdaki listede aranan kelimeler var.',
        'Izgarada harflerin üzerinde parmağını sürükle.',
        'Kelimeler yatay, dikey veya çapraz olabilir.',
        'Hepsini bularak seviyeyi tamamla.',
      ],
    ),
    RouteConstants.wordChain: GameGuide(
      title: 'Kelime Zinciri',
      icon: Icons.link_rounded,
      accent: AppColors.word,
      steps: [
        'Bir kelime yaz; zincir başlasın.',
        'Sonraki kelime öncekinin son harfiyle başlamalı.',
        'Gerçek Türkçe kelime olmalı, tekrar olmamalı.',
        'Uzun kelimeler daha çok puan getirir.',
      ],
    ),
    RouteConstants.anagram: GameGuide(
      title: 'Karışık Harfler',
      icon: Icons.shuffle_rounded,
      accent: AppColors.word,
      steps: [
        'Harfler karışık olarak verilir.',
        'Harflere dokunarak cevap satırını doldur.',
        'Geçerli bir kelime oluştur — satır dolunca denetlenir.',
        'Yanlış harfi geri almak için üstüne dokun.',
      ],
    ),
    RouteConstants.letterSearch: GameGuide(
      title: 'Harf Arama',
      icon: Icons.search_rounded,
      accent: AppColors.visual,
      steps: [
        'Üstte bir hedef harf gösterilir.',
        'Izgarada o harfin tüm kopyalarına dokun.',
        'Hızlı tara — gözünü gezdirerek bul.',
        'Yanlış harfe dokunmak süre kaybettirir.',
      ],
    ),
    RouteConstants.eyeFocus: GameGuide(
      title: 'Göz Odaklama',
      icon: Icons.center_focus_strong_rounded,
      accent: AppColors.visual,
      steps: [
        'Izgarada 1’den 36’ya sayılar karışık durur.',
        'Sayılara sırayla (1, 2, 3…) dokun.',
        'Bakışını merkezde tutmaya çalış.',
        'Amaç: tabloyu en kısa sürede bitirmek.',
      ],
    ),
    RouteConstants.peripheralVision: GameGuide(
      title: 'Çevresel Görüş',
      icon: Icons.blur_circular_rounded,
      accent: AppColors.visual,
      steps: [
        'Gözünü ekranın ortasındaki noktada tut.',
        'Çevredeki noktalardan biri kısa süre parlar.',
        'Hangisinin parladığını çevresel görüşle yakala.',
        'Sonra o noktaya dokun.',
      ],
    ),
    RouteConstants.speedReadingExercise: GameGuide(
      title: 'Hızlı Okuma',
      icon: Icons.speed_rounded,
      accent: AppColors.reading,
      steps: [
        'Bir okuma temposu seç.',
        'Kelimeler ekranda tek tek hızlıca akar.',
        'Gözünü kaydırmadan kelimeleri takip et.',
        'Sonunda okuma özetini gör.',
      ],
    ),
  };
}
