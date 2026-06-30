import 'package:flutter/widgets.dart';

import 'ads/ad_service.dart';
import 'feedback/achievements.dart';
import 'feedback/daily_challenge.dart';
import 'feedback/game_settings.dart';
import 'feedback/music_service.dart';
import 'feedback/records.dart';
import 'feedback/sound_service.dart';
import 'iap/purchases.dart';
import 'onboarding/guides.dart';
import 'words/word_service.dart';

/// One-time app initialisation. Run from the splash screen (not in main before
/// runApp) so the animated splash paints immediately and the heavy loading —
/// the 49k-word dictionary, audio, ads, billing — happens behind it.
Future<void> bootstrap() async {
  await WordService.load();
  await SoundService.instance.load();
  await MusicService.instance.init();
  await Records.instance.init();
  await Achievements.instance.init();
  await GameSettings.instance.init();
  await Guides.instance.init();
  await DailyChallenge.instance.init();
  await AdService.instance.init();
  await Purchases.instance.init();

  // Fires the app-open ad when the app returns to the foreground.
  AppLifecycleListener(onResume: AdService.instance.showAppOpenIfReady);
}
