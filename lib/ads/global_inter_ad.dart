import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef AdEventCallback = void Function(String? adPlacement);
typedef AdLoadFailedCallback = void Function(
  String? adPlacement,
  LoadAdError error,
);
typedef AdPaidCallback = void Function(
  String? adPlacement,
  double valueMicros,
  PrecisionType precision,
  String currencyCode,
);

/// Global singleton helper for loading and showing a single interstitial ad.
///
/// Typical usage:
/// ```dart
/// GlobalInterAd.loadAd(adUnitId: 'ca-app-pub-xxx');
/// // later...
/// GlobalInterAd.showAd();
///
/// // or load + show immediately once ready:
/// GlobalInterAd.loadAd(adUnitId: 'ca-app-pub-xxx', immediately: true);
/// ```
class GlobalInterAd {
  GlobalInterAd._();

  static const int defaultLoadTimeoutMs = 5000;

  static InterstitialAd? _ad;
  static bool _isLoading = false;
  static Timer? _timeoutTimer;
  static bool _loadTimedOut = false;

  // Callbacks / context for the current load cycle.
  static AdEventCallback? _onLoaded;
  static AdLoadFailedCallback? _onLoadFailed;
  static AdEventCallback? _onImpression;
  static AdEventCallback? _onClicked;
  static AdPaidCallback? _onPaid;
  static AdEventCallback? _onShow;
  static String? _adPlacement;
  static bool _showImmediately = false;

  static bool get isLoading => _isLoading;
  static bool get isReady => _ad != null;

  /// Loads an interstitial ad.
  ///
  /// If [immediately] is true, [showAd] is called automatically as soon as the
  /// ad finishes loading.
  ///
  /// If loading takes longer than [loadTimeout] ms, the load is considered
  /// failed: when the ad eventually arrives it will be disposed instead of
  /// shown. [onLoadFailed] is still invoked with a timeout error.
  static void loadAd({
    required String adUnitId,
    bool immediately = false,
    AdEventCallback? onLoaded,
    AdLoadFailedCallback? onLoadFailed,
    AdEventCallback? onImpression,
    AdEventCallback? onClicked,
    AdPaidCallback? onPaid,
    AdEventCallback? onShow,
    String? adPlacement,
    int loadTimeout = defaultLoadTimeoutMs,
  }) {
    if (_isLoading) {
      debugPrint('[GlobalInterAd] loadAd skipped — already loading.');
      return;
    }

    if (_ad != null) {
      debugPrint('[GlobalInterAd] Ad already cached.');
      onLoaded?.call(adPlacement);
      if (immediately) {
        showAd(onShow: onShow);
      }
      return;
    }

    _isLoading = true;
    _loadTimedOut = false;
    _onLoaded = onLoaded;
    _onLoadFailed = onLoadFailed;
    _onImpression = onImpression;
    _onClicked = onClicked;
    _onPaid = onPaid;
    _onShow = onShow;
    _adPlacement = adPlacement;
    _showImmediately = immediately;

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(milliseconds: loadTimeout), () {
      if (!_isLoading) return;
      _loadTimedOut = true;
      debugPrint(
        '[GlobalInterAd] Load timeout after ${loadTimeout}ms '
        '(placement: $_adPlacement)',
      );
      _onLoadFailed?.call(
        _adPlacement,
        LoadAdError(
          -1,
          'GlobalInterAd',
          'Load timeout after ${loadTimeout}ms',
          null,
        ),
      );
    });

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isLoading = false;
          _timeoutTimer?.cancel();

          if (_loadTimedOut) {
            debugPrint(
              '[GlobalInterAd] Ad loaded after timeout — disposing.',
            );
            ad.dispose();
            _clearCycle();
            return;
          }

          _ad = ad;
          _attachFullScreenCallbacks(ad);
          ad.onPaidEvent = (
            Ad _,
            double valueMicros,
            PrecisionType precision,
            String currencyCode,
          ) {
            _onPaid?.call(_adPlacement, valueMicros, precision, currencyCode);
          };

          debugPrint('[GlobalInterAd] Ad loaded (placement: $_adPlacement).');
          _onLoaded?.call(_adPlacement);

          if (_showImmediately) {
            showAd(onShow: _onShow);
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          _timeoutTimer?.cancel();

          if (_loadTimedOut) {
            // onLoadFailed already reported via the timeout path.
            _clearCycle();
            return;
          }

          debugPrint('[GlobalInterAd] Ad failed to load: $error');
          _onLoadFailed?.call(_adPlacement, error);
          _clearCycle();
        },
      ),
    );
  }

  /// Shows the currently loaded interstitial ad, if any.
  ///
  /// [onShow] overrides the callback passed to [loadAd] for this invocation.
  static void showAd({AdEventCallback? onShow}) {
    final ad = _ad;
    if (ad == null) {
      debugPrint('[GlobalInterAd] showAd called but no ad is ready.');
      return;
    }

    // Consume the cached ad — interstitials are one-shot.
    _ad = null;

    final cb = onShow ?? _onShow;
    cb?.call(_adPlacement);

    ad.show();
  }

  static void _attachFullScreenCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[GlobalInterAd] Ad showed full screen content.');
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[GlobalInterAd] Failed to show full screen: $err');
        ad.dispose();
        _clearCycle();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[GlobalInterAd] Ad dismissed.');
        ad.dispose();
        _clearCycle();
      },
      onAdImpression: (ad) {
        _onImpression?.call(_adPlacement);
      },
      onAdClicked: (ad) {
        _onClicked?.call(_adPlacement);
      },
    );
  }

  static void _clearCycle() {
    _onLoaded = null;
    _onLoadFailed = null;
    _onImpression = null;
    _onClicked = null;
    _onPaid = null;
    _onShow = null;
    _adPlacement = null;
    _showImmediately = false;
    _loadTimedOut = false;
  }
}
