import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../design/app_colors.dart';

/// AdMob unit ids. Debug builds use Google's official TEST ids so we never
/// serve (or accidentally click) live ads during development — that would risk
/// an AdMob ban. Release builds use the real ids.
class AdIds {
  AdIds._();

  static const _banner = 'ca-app-pub-4716033743179769/1012621342';
  static const _interstitial = 'ca-app-pub-4716033743179769/3195510093';
  static const _rewarded = 'ca-app-pub-4716033743179769/4243465516';
  static const _appOpen = 'ca-app-pub-4716033743179769/3003938409';

  // Google sample/test unit ids (Android).
  static const _tBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _tInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _tRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const _tAppOpen = 'ca-app-pub-3940256099942544/9257395921';

  static const bool useTest = !kReleaseMode;

  static String get banner => useTest ? _tBanner : _banner;
  static String get interstitial => useTest ? _tInterstitial : _interstitial;
  static String get rewarded => useTest ? _tRewarded : _rewarded;
  static String get appOpen => useTest ? _tAppOpen : _appOpen;
}

/// Loads and shows AdMob ads. One instance for the app:
/// - interstitial shown every Nth game exit (frequency-capped),
/// - rewarded shown on demand (continue / refill power-ups),
/// - banners via [BannerAdSlot].
///
/// Ads can be globally disabled (e.g. a future "remove ads" purchase) by
/// setting [enabled] = false.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool enabled = true;
  bool _ready = false;

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _ready = true;
      _loadInterstitial();
      _loadRewarded();
    } catch (e) {
      debugPrint('AdService init error: $e');
    }
  }

  // ── Interstitial ───────────────────────────────────────────────────────────
  InterstitialAd? _interstitial;
  int _exitsSinceAd = 0;
  static const int _interstitialEvery = 3;

  void _loadInterstitial() {
    if (!_ready || !enabled) return;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Shows an interstitial every [_interstitialEvery] calls, if one is loaded.
  void maybeShowInterstitial() {
    if (!enabled) return;
    _exitsSinceAd++;
    if (_exitsSinceAd < _interstitialEvery) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _exitsSinceAd = 0;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  // ── Rewarded ─────────────────────────────────────────────────────────────────
  RewardedAd? _rewarded;

  bool get rewardedReady => _rewarded != null;

  void _loadRewarded() {
    if (!_ready) return;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (_) => _rewarded = null,
      ),
    );
  }

  /// Shows a rewarded ad. [onReward] runs only if the user earns the reward.
  /// [onUnavailable] runs if no ad was ready (so the caller can fall back).
  void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onUnavailable,
  }) {
    final ad = _rewarded;
    if (ad == null) {
      onUnavailable?.call();
      _loadRewarded();
      return;
    }
    _rewarded = null;
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (earned) onReward();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        onUnavailable?.call();
      },
    );
    ad.show(onUserEarnedReward: (_, __) => earned = true);
  }
}

/// A standard 320x50 banner slot. Loads on mount, disposes on unmount, and
/// renders nothing until (and unless) an ad actually loads, so layout never
/// jumps for a missing ad.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService.instance.enabled) _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _ad!.size.height.toDouble(),
      color: AppColors.bgDeep,
      child: AdWidget(ad: _ad!),
    );
  }
}
