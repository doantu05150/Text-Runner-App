import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'global_inter_ad.dart'
    show AdPlacementCallback, AdLoadFailedCallback, AdPaidCallback;

/// Builder that turns a loaded [NativeAd] into a widget subtree.
///
/// Typically the returned widget wraps an [AdWidget] so that the ad's asset
/// views (headline, body, CTA, etc.) are actually rendered:
///
/// ```dart
/// content: (ad) => SizedBox(
///   height: 120,
///   child: AdWidget(ad: ad),
/// ),
/// ```
typedef NativeAdContentBuilder = Widget Function(NativeAd ad);

/// A self-contained native ad widget.
///
/// Loads a [NativeAd] on mount using the supplied [adUnitId] and
/// [factoryId] (which must be registered on the native side — see the
/// google_mobile_ads docs for `NativeAdFactory`). While loading, it shows
/// [placeholder]. Once loaded, it delegates rendering to [content].
///
/// Example:
/// ```dart
/// GlobalNativeAd(
///   adUnitId: 'ca-app-pub-xxx/yyy',
///   factoryId: 'homeBottom',
///   adPlacement: 'home_bottom',
///   placeholder: const SizedBox(height: 120, child: Center(
///     child: CircularProgressIndicator(),
///   )),
///   content: (ad) => SizedBox(height: 120, child: AdWidget(ad: ad)),
/// )
/// ```
class GlobalNativeAd extends StatefulWidget {
  const GlobalNativeAd({
    super.key,
    required this.adUnitId,
    required this.factoryId,
    required this.content,
    this.placeholder,
    this.onLoaded,
    this.onLoadFailed,
    this.onImpression,
    this.onClicked,
    this.onPaid,
    this.adPlacement,
  });

  final String adUnitId;

  /// ID of a `NativeAdFactory` registered on the native (Android / iOS)
  /// side. Required by google_mobile_ads to build the platform ad view.
  final String factoryId;

  /// Builder for the widget shown once the ad is loaded.
  final NativeAdContentBuilder content;

  /// Widget shown while the ad is loading. Also shown (briefly) if no ad
  /// has been received yet. If null, an empty [SizedBox] is used.
  final Widget? placeholder;

  final AdPlacementCallback? onLoaded;
  final AdLoadFailedCallback? onLoadFailed;
  final AdPlacementCallback? onImpression;
  final AdPlacementCallback? onClicked;
  final AdPaidCallback? onPaid;
  final String? adPlacement;

  @override
  State<GlobalNativeAd> createState() => _GlobalNativeAdState();
}

class _GlobalNativeAdState extends State<GlobalNativeAd> {
  NativeAd? _nativeAd;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didUpdateWidget(covariant GlobalNativeAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adUnitId != widget.adUnitId ||
        oldWidget.factoryId != widget.factoryId) {
      _disposeAd();
      _failed = false;
      _loadAd();
    }
  }

  void _loadAd() {
    final ad = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: widget.factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onPaidEvent: (
          Ad _,
          double valueMicros,
          PrecisionType precision,
          String currencyCode,
        ) {
          widget.onPaid?.call(
            widget.adPlacement,
            valueMicros,
            precision,
            currencyCode,
          );
        },
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _nativeAd = ad as NativeAd);
          widget.onLoaded?.call(widget.adPlacement);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('[GlobalNativeAd] Failed to load: $error');
          ad.dispose();
          if (!mounted) return;
          setState(() => _failed = true);
          widget.onLoadFailed?.call(widget.adPlacement, error);
        },
        onAdImpression: (Ad ad) {
          widget.onImpression?.call(widget.adPlacement);
        },
        onAdClicked: (Ad ad) {
          widget.onClicked?.call(widget.adPlacement);
        },
      ),
    );

    ad.load();
  }

  void _disposeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _nativeAd;
    if (ad != null) {
      return widget.content(ad);
    }
    if (_failed) {
      return const SizedBox.shrink();
    }
    return widget.placeholder ?? const SizedBox.shrink();
  }
}
