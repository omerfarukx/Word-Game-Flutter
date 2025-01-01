import '../domain/models/achievement.dart';

class AchievementsData {
  static final List<Achievement> achievements = [
    Achievement(
      id: 'first_win',
      title: 'İlk Zafer!',
      description: 'İlk bölümü tamamladın',
      badgeAsset: 'assets/badges/first_win.png',
      requiredScore: 100,
    ),
    Achievement(
      id: 'combo_master',
      title: 'Kombo Ustası',
      description: '5 kombo yaptın',
      badgeAsset: 'assets/badges/combo_master.png',
      requiredScore: 500,
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Hız Şeytanı',
      description: 'Bir bölümü 20 saniyeden kısa sürede bitirdin',
      badgeAsset: 'assets/badges/speed_demon.png',
      requiredScore: 1000,
    ),
    Achievement(
      id: 'perfect_round',
      title: 'Mükemmel Tur',
      description: 'Hiç hata yapmadan bir bölüm bitirdin',
      badgeAsset: 'assets/badges/perfect_round.png',
      requiredScore: 2000,
    ),
    Achievement(
      id: 'hint_master',
      title: 'İpucu Ustası',
      description: 'İpucu kullanmadan 3 bölüm bitirdin',
      badgeAsset: 'assets/badges/hint_master.png',
      requiredScore: 3000,
    ),
  ];
}
