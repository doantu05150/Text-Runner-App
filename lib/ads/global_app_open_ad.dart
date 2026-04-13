import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Global singleton for App Open ads.
///
/// Two use cases:
///   1. **Cold start** — call [loadAd] on the splash screen. When the splash
///      finishes, call [showAdIfReady]. If the ad isn't loaded yet, nothing
///      happens.
///   2. **Resume** — register [GlobalAppOpenAd.instance] as an
///      [AppLifecycleListener] callback. When the app resumes from the
///      background, an ad is loaded and shown immediately.
class GlobalAppOpenAd with WidgetsBindingObserver {
  GlobalAppOpenAd._();
  static final GlobalAppOpenAd instance = GlobalAppOpenAd._();

  static const String _adUnitId = 'ca-app-pub-2729665939843867/2526296452';

  AppOpenAd? _ad;
  bool _isLoading = false;
  bool _isShowing = false;

  /// Timestamp of the last successful load. App Open ads expire after 4 hours.
  DateTime? _loadedAt;
  static const Duration _adExpiry = Duration(hours: 4);

  /// Start observing app lifecycle for resume events.
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Stop observing (call if you ever need to tear down).
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ad?.dispose();
    _ad = null;
  }

  /// Whether a valid (non-expired) ad is ready to show.
  bool get isReady {
    if (_ad == null || _loadedAt == null) return false;
    return DateTime.now().difference(_loadedAt!) < _adExpiry;
  }

  /// Loads an App Open ad. If [onLoaded] is provided, it fires once the ad
  /// is ready.
  void loadAd({VoidCallback? onLoaded}) {
    if (_isLoading || isReady) {
      if (isReady) onLoaded?.call();
      return;
    }

    _isLoading = true;

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _isLoading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
          debugPrint('[GlobalAppOpenAd] Ad loaded.');
          onLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          debugPrint('[GlobalAppOpenAd] Failed to load: $error');
        },
      ),
    );
  }

  /// Shows the ad if one is loaded and not expired. Returns `true` if an ad
  /// was shown, `false` otherwise.
  bool showAdIfReady({VoidCallback? onDismissed}) {
    if (!isReady || _isShowing) {
      onDismissed?.call();
      return false;
    }

    _isShowing = true;
    final ad = _ad!;
    _ad = null;
    _loadedAt = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[GlobalAppOpenAd] Ad showed.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[GlobalAppOpenAd] Failed to show: $error');
        ad.dispose();
        _isShowing = false;
        onDismissed?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[GlobalAppOpenAd] Ad dismissed.');
        ad.dispose();
        _isShowing = false;
        onDismissed?.call();
      },
    );

    ad.show();
    return true;
  }

  // -- App lifecycle: load & show on resume --

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isShowing) {
      _loadAndShow();
    }
  }

  void _loadAndShow() {
    if (isReady) {
      showAdIfReady();
      return;
    }

    loadAd(onLoaded: () {
      showAdIfReady();
    });
  }
}
