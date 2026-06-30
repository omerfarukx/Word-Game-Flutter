import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ad_service.dart';

/// "Reklamları Kaldır" — a one-time non-consumable purchase that disables all
/// ads ([AdService.enabled] = false). The grant is persisted so it survives
/// restarts, and [restorePurchases] re-grants it on a reinstall / new device.
///
/// Requires a non-consumable product with id [removeAdsId] configured in the
/// Play Console, and the app published to a testing track to actually buy.
class Purchases extends ChangeNotifier {
  Purchases._();
  static final Purchases instance = Purchases._();

  static const String removeAdsId = 'remove_ads';
  static const String _key = 'remove_ads_purchased';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _removeAds;
  bool _purchased = false;

  /// Whether the store is reachable (false on devices without Play billing).
  bool storeAvailable = false;

  bool get purchased => _purchased;
  String? get price => _removeAds?.price;
  bool get canBuy => storeAvailable && _removeAds != null && !_purchased;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _purchased = prefs.getBool(_key) ?? false;
      if (_purchased) AdService.instance.enabled = false;

      storeAvailable = await _iap.isAvailable();
      if (!storeAvailable) {
        notifyListeners();
        return;
      }

      _sub = _iap.purchaseStream.listen(
        _onPurchases,
        onDone: () => _sub?.cancel(),
        onError: (_) {},
      );

      final resp = await _iap.queryProductDetails({removeAdsId});
      if (resp.productDetails.isNotEmpty) {
        _removeAds = resp.productDetails.first;
      }
      // Re-grant a prior purchase on reinstall / new install.
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('Purchases init error: $e');
    }
    notifyListeners();
  }

  /// Starts the purchase flow. No-op if unavailable or already owned.
  Future<void> buyRemoveAds() async {
    final product = _removeAds;
    if (product == null || _purchased) return;
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      debugPrint('buyRemoveAds error: $e');
    }
  }

  Future<void> restore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('restore error: $e');
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID == removeAdsId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        await _grant();
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  Future<void> _grant() async {
    if (_purchased) return;
    _purchased = true;
    AdService.instance.enabled = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
