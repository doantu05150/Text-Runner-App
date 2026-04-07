import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'global_native_ad.dart';

/// Native ad shown below the Play button on the home screen.
///
/// The visual layout (Ad Info row with icon/name/body/star, Ad badge,
/// Ad media in 16:9, and CTA button) is assembled by the platform-side
/// `NativeAdFactory` registered with [factoryId]. This widget only owns
/// the outer card styling (full-width, bgCard, 12px content padding,
/// no border radius) and the height allocation for the AdWidget.
class HomeBottomNativeAd extends StatelessWidget {
  const HomeBottomNativeAd({super.key});

  // Google test native ad unit id.
  static const String _adUnitId = 'ca-app-pub-3940256099942544/2247696110';
  static const String _factoryId = 'homeBottomNativeAd';

  // Internal element heights (must match the native factory layout).
  static const double _adInfoHeight = 56;
  static const double _badgeHeight = 16;
  static const double _ctaHeight = 44;
  static const double _gap = 8;
  static const double _outerPadding = 12;

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
    return Container(
      width: double.infinity,
      color: const Color(0xFF121821),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
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
            adPlacement: 'home_bottom',
            content: (ad) => SizedBox(
              height: totalHeight,
              child: AdWidget(ad: ad),
            ),
          );
        },
      ),
    );
  }
}
