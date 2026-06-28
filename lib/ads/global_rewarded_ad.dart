import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_cooldown.dart';

typedef RewardedPlacementCallback = void Function(String? adPlacement);
typedef RewardedLoadFailedCallback = void Function(
  String? adPlacement,
  LoadAdError error,
);
typedef RewardedEarnedCallback = void Function(
  String? adPlacement,
  RewardItem reward,
);
typedef RewardedDismissedCallback = void Function(
  String? adPlacement,
  bool earned,
);

/// Global singleton helper for loading and showing a single rewarded ad.
///
/// Typical usage:
/// ```dart
/// GlobalRewardedAd.loadAd(adUnitId: 'ca-app-pub-xxx');
/// // later...
/// GlobalRewardedAd.showAd(
///   onEarned: (_, __) => unlock(),
///   onDismissed: (_, earned) { if (!earned) warn(); preloadNext(); },
/// );
/// ```
class GlobalRewardedAd {
  GlobalRewardedAd._();

  static const int defaultLoadTimeoutMs = 15000;

  static RewardedAd? _ad;
  static bool _isLoading = false;
  static Timer? _timeoutTimer;
  static bool _loadTimedOut = false;

  // Load-cycle context.
  static RewardedPlacementCallback? _onLoaded;
  static RewardedLoadFailedCallback? _onLoadFailed;
  static String? _adPlacement;

  static bool get isLoading => _isLoading;
  static bool get isReady => _ad != null;

  /// Loads a rewarded ad. No-op if one is already loading or cached.
  ///
  /// [onLoaded] / [onLoadFailed] report the outcome of THIS load request even
  /// if an ad is already cached (in which case [onLoaded] fires immediately).
  static void loadAd({
    required String adUnitId,
    RewardedPlacementCallback? onLoaded,
    RewardedLoadFailedCallback? onLoadFailed,
    String? adPlacement,
    int loadTimeout = defaultLoadTimeoutMs,
  }) {
    if (_ad != null) {
      debugPrint('[GlobalRewardedAd] Ad already cached.');
      onLoaded?.call(adPlacement);
      return;
    }

    if (_isLoading) {
      debugPrint('[GlobalRewardedAd] loadAd skipped — already loading.');
      // Chain the new callbacks onto the in-flight load so a waiting caller
      // is still notified when it resolves.
      final prevLoaded = _onLoaded;
      final prevFailed = _onLoadFailed;
      _onLoaded = (p) {
        prevLoaded?.call(p);
        onLoaded?.call(p);
      };
      _onLoadFailed = (p, e) {
        prevFailed?.call(p, e);
        onLoadFailed?.call(p, e);
      };
      return;
    }

    _isLoading = true;
    _loadTimedOut = false;
    _onLoaded = onLoaded;
    _onLoadFailed = onLoadFailed;
    _adPlacement = adPlacement;

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(milliseconds: loadTimeout), () {
      if (!_isLoading) return;
      _loadTimedOut = true;
      debugPrint(
        '[GlobalRewardedAd] Load timeout after ${loadTimeout}ms '
        '(placement: $_adPlacement)',
      );
      _onLoadFailed?.call(
        _adPlacement,
        LoadAdError(
          -1,
          'GlobalRewardedAd',
          'Load timeout after ${loadTimeout}ms',
          null,
        ),
      );
    });

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isLoading = false;
          _timeoutTimer?.cancel();

          if (_loadTimedOut) {
            debugPrint('[GlobalRewardedAd] Ad loaded after timeout — disposing.');
            ad.dispose();
            _clearLoadCycle();
            return;
          }

          _ad = ad;
          // Snapshot + clear BEFORE invoking so a re-entrant loadAd() inside
          // the callback can install a fresh cycle without it being wiped.
          final onLoaded = _onLoaded;
          final placement = _adPlacement;
          _clearLoadCycle();
          debugPrint('[GlobalRewardedAd] Ad loaded (placement: $placement).');
          onLoaded?.call(placement);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          _timeoutTimer?.cancel();

          if (_loadTimedOut) {
            _clearLoadCycle();
            return;
          }

          // Snapshot + clear BEFORE invoking so a re-entrant loadAd() (e.g. a
          // retry) inside the callback installs a fresh cycle that survives.
          final onLoadFailed = _onLoadFailed;
          final placement = _adPlacement;
          _clearLoadCycle();
          debugPrint('[GlobalRewardedAd] Ad failed to load: $error');
          onLoadFailed?.call(placement, error);
        },
      ),
    );
  }

  /// Shows the cached rewarded ad, if any.
  ///
  /// [onEarned] fires when the user earns the reward. [onDismissed] fires once
  /// the ad closes (or immediately if no ad is cached) with whether the reward
  /// was earned during this show.
  static void showAd({
    RewardedEarnedCallback? onEarned,
    RewardedDismissedCallback? onDismissed,
  }) {
    final ad = _ad;
    if (ad == null) {
      debugPrint('[GlobalRewardedAd] showAd called but no ad is ready.');
      onDismissed?.call(_adPlacement, false);
      return;
    }

    // Consume the cached ad — rewarded ads are one-shot.
    _ad = null;
    final placement = _adPlacement;
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        AdCooldown.recordShown();
        debugPrint('[GlobalRewardedAd] Ad showed full screen content.');
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[GlobalRewardedAd] Failed to show full screen: $err');
        ad.dispose();
        onDismissed?.call(placement, false);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[GlobalRewardedAd] Ad dismissed (earned: $earned).');
        ad.dispose();
        onDismissed?.call(placement, earned);
      },
    );

    ad.show(
      onUserEarnedReward: (Ad _, RewardItem reward) {
        earned = true;
        debugPrint('[GlobalRewardedAd] User earned reward: ${reward.amount}.');
        onEarned?.call(placement, reward);
      },
    );
  }

  static void _clearLoadCycle() {
    _onLoaded = null;
    _onLoadFailed = null;
    _adPlacement = null;
    _loadTimedOut = false;
  }
}
