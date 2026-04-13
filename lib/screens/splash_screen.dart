import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/global_app_open_ad.dart';
import '../ads/global_native_ad.dart';
import '../ads/native_ad_cache.dart';
import '../theme/app_theme.dart';

/// First screen shown on app launch.
///
/// Layout (top to bottom): centered logo, a 5-second fake progress bar,
/// and a native ad. The ad is loaded the moment this screen mounts and
/// shown as soon as it is ready. While here, we also preload the native
/// ad for the first onboarding screen so it can render instantly if the
/// user is new.
///
/// The splash stays visible until both:
///   * the fake progress has reached 100% (≥5s), and
///   * the native ad has been visible for ≥1s (or failed / never
///     arrived — in which case we just move on once progress finishes).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _minDuration = Duration(seconds: 5);
  static const Duration _minAdVisible = Duration(seconds: 2);

  // Google test native ad unit id — matches HomeBottomNativeAd so the
  // same platform NativeAdFactory ('homeBottomNativeAd') is reused.
  static const String _nativeAdUnitId =
      'ca-app-pub-2729665939843867/1814803830';
  static const String _nativeFactoryId = 'homeBottomNativeAd';

  static const String _onb1AdKey = 'onb_native_1';
  static const String _firstLaunchDoneKey = 'app.first_launch_done';

  late final AnimationController _progressCtrl;
  DateTime? _adShownAt;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: _minDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _maybeNavigate();
      })
      ..forward();

    // Preload the app open ad so it's ready when the splash finishes.
    GlobalAppOpenAd.instance.loadAd();

    // Warm the cache for onboarding screen 1 so it renders instantly if
    // the user is new. One-shot — don't auto-refill.
    NativeAdCache.preload(
      key: _onb1AdKey,
      adUnitId: _nativeAdUnitId,
      factoryId: _nativeFactoryId,
    );
  }

  void _onAdLoaded(String? _) {
    _adShownAt ??= DateTime.now();
    _maybeNavigate();
  }

  void _onAdFailed(String? _, LoadAdError __) {
    // Treat a failed load as "no ad to wait for"; progress still gates us.
    _maybeNavigate();
  }

  Future<void> _maybeNavigate() async {
    if (_navigated || !mounted) return;
    if (_progressCtrl.status != AnimationStatus.completed) return;

    // If the ad has been shown, wait out the minimum visible time.
    final shownAt = _adShownAt;
    if (shownAt != null) {
      final visibleFor = DateTime.now().difference(shownAt);
      if (visibleFor < _minAdVisible) {
        await Future<void>.delayed(_minAdVisible - visibleFor);
        if (!mounted || _navigated) return;
      }
    }

    _navigated = true;
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool(_firstLaunchDoneKey) ?? false;
    if (!mounted) return;

    final route = seenOnboarding ? '/' : '/onboarding/1';

    // Show the app open ad before navigating. If no ad is ready, navigate
    // immediately.
    final shown = GlobalAppOpenAd.instance.showAdIfReady(
      onDismissed: () {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(route);
      },
    );
    if (!shown) {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 96,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'GlowTextify',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedBuilder(
                  animation: _progressCtrl,
                  builder: (context, _) => LinearProgressIndicator(
                    value: _progressCtrl.value,
                    minHeight: 6,
                    backgroundColor: AppColors.bgCard,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GlobalNativeAd(
              adUnitId: _nativeAdUnitId,
              factoryId: _nativeFactoryId,
              adPlacement: 'splash_native',
              onLoaded: _onAdLoaded,
              onLoadFailed: _onAdFailed,
              content: (ad) => SizedBox(
                height: 280,
                child: AdWidget(ad: ad),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
