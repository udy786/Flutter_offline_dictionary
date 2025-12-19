import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// iOS Banner Ad Unit ID
  static const String _iosBannerAdUnitId = 'ca-app-pub-6174288335500940/9670395824';

  /// Test Banner Ad Unit ID (for development)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';

  /// Get the appropriate banner ad unit ID
  String get bannerAdUnitId {
    if (kDebugMode) {
      // Use test ads in debug mode
      return _testBannerAdUnitId;
    }
    if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    // Return test ad for other platforms (Android not configured yet)
    return _testBannerAdUnitId;
  }

  /// Check if ads should be shown (iOS only for now)
  bool get shouldShowAds => Platform.isIOS;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!shouldShowAds) {
      debugPrint('AdService: Ads not supported on this platform');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdService: Mobile Ads SDK initialized');
    } catch (e) {
      debugPrint('AdService: Failed to initialize Mobile Ads SDK: $e');
    }
  }

  /// Create a banner ad
  /// Uses non-personalized ads to respect user privacy (no tracking)
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(
        // Request only non-personalized ads (no user tracking required)
        nonPersonalizedAds: true,
      ),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('AdService: Banner ad opened'),
        onAdClosed: (ad) => debugPrint('AdService: Banner ad closed'),
        onAdImpression: (ad) => debugPrint('AdService: Banner ad impression'),
      ),
    );
  }
}
