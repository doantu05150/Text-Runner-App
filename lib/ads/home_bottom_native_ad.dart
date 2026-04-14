import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'global_inter_ad.dart' show AdPlacementCallback;
import 'global_native_ad.dart';
import 'native_ad_cache.dart';

/// Native ad shown below the Play button on the home screen.
///
/// The visual layout (Ad Info row with icon/name/body/star, Ad badge,
/// Ad media in 16:9, and CTA button) is assembled by the platform-side
/// `NativeAdFactory` registered with [factoryId]. This widget only owns
/// the outer card styling (full-width, bgCard, 12px content padding,
/// no border radius) and the height allocation for the AdWidget.
class HomeBottomNativeAd extends StatelessWidget {
  const HomeBottomNativeAd({
    super.key,
    this.placement = 'home_bottom',
    this.cacheKey = 'home_bottom',
    this.cacheAutoRefill = true,
    this.onLoaded,
  });

  /// Analytics label passed through to [GlobalNativeAd]. Override when
  /// reusing this layout on a different screen (e.g. `'settings_bottom'`).
  final String placement;

  /// Cache slot to consume from / preload into. Using distinct keys
  /// per placement lets us hand off ads from one screen to the next
  /// (e.g. splash → onboarding 1 → onboarding 2 → ...).
  final String cacheKey;

  /// Whether the cache should refill itself after consume. Disable for
  /// one-shot screens like splash and onboarding to avoid loading an
  /// ad that will never be shown.
  final bool cacheAutoRefill;

  /// Fires once the ad has loaded (either from cache or fresh). Useful
  /// for gating UI affordances like an enabled "Next" button.
  final AdPlacementCallback? onLoaded;

  // Google test native ad unit id.
  static const String _adUnitId = 'ca-app-pub-2729665939843867/8294237260';
  static const String _factoryId = 'homeBottomNativeAd';

  // Internal element heights (must match the native factory layout).
  static const double _adInfoHeight = 56;
  static const double _badgeHeight = 16;
  static const double _ctaHeight = 44;
  static const double _gap = 8;
  static const double _outerPadding = 12;

  /// Default cache slot used by the home-bottom placement.
  static const String defaultCacheKey = 'home_bottom';

  /// Warm the [NativeAdCache] for this placement so the next instance
  /// of this widget can render instantly. Safe to call multiple times;
  /// no-op if the cache is already filled or a load is in flight.
  static void preload({String key = defaultCacheKey}) {
    NativeAdCache.preload(
      key: key,
      adUnitId: _adUnitId,
      factoryId: _factoryId,
    );
  }

  /// Total rendered height of the ad card for the given outer [width].
  /// Used by the home screen to reserve scroll padding behind the
  /// absolutely-positioned ad.
  static double heightForWidth(double width) {
    final innerWidth = width - _outerPadding * 2;
    final mediaHeight = innerWidth * 9 / 16;
    return _outerPadding * 2
        + _adInfoHeight
        + _gap
        + _badgeHeight
        + _gap
        + mediaHeight
        + _gap
        + _ctaHeight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaHeight = constraints.maxWidth * 9 / 28;
        final totalHeight = _adInfoHeight
            + _gap
            + _badgeHeight
            + _gap
            + mediaHeight
            + _gap
            + _ctaHeight;

        return GlobalNativeAd(
          adUnitId: _adUnitId,
          factoryId: _factoryId,
          adPlacement: placement,
          useCache: true,
          cacheKey: cacheKey,
          cacheAutoRefill: cacheAutoRefill,
          onLoaded: onLoaded,
          content: (ad) => Container(
            width: double.infinity,
            color: const Color(0xFF121821),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              height: totalHeight,
              child: AdWidget(ad: ad),
            ),
          ),
        );
      },
    );
  }
}
