import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ad_ids.dart';
import '../ads/global_native_ad.dart';
import '../ads/native_ad_cache.dart';
import '../theme/app_theme.dart';
const String _firstLaunchDoneKey = 'app.first_launch_done';

/// Screen 1 of the first-run tour: "easy to use".
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.touch_app_outlined,
      title: 'Easy to use',
      description:
          'Type your message and tap Play — that\'s it. GlowTextify turns '
          'your phone into a big, bright scrolling display in one tap.',
      buttonLabel: 'Next',
      myCacheKey: 'onb_native_1',
      nextCacheKey: 'onb_native_2',
      onNext: (ctx) =>
          Navigator.of(ctx).pushReplacementNamed('/onboarding/2'),
    );
  }
}

/// Screen 2 of the first-run tour: customization.
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.palette_outlined,
      title: 'Make it yours',
      description:
          'Pick colors, backgrounds, fonts, speed and effects — tailor '
          'every detail to match the vibe you want.',
      buttonLabel: 'Next',
      myCacheKey: 'onb_native_2',
      nextCacheKey: 'onb_native_3',
      onNext: (ctx) =>
          Navigator.of(ctx).pushReplacementNamed('/onboarding/3'),
    );
  }
}

/// Screen 3 of the first-run tour: saved items + start.
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.bookmark_outline,
      title: 'Save your favorites',
      description:
          'Keep the messages you use often in Saved items and recall '
          'them in a single tap whenever you need them.',
      buttonLabel: 'Start',
      myCacheKey: 'onb_native_3',
      nextCacheKey: null,
      onNext: (ctx) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_firstLaunchDoneKey, true);
        if (!ctx.mounted) return;
        Navigator.of(ctx).pushReplacementNamed('/');
      },
    );
  }
}

/// Shared layout + ad-gating logic for an onboarding page.
///
/// Behavior:
///   * On mount, preloads the NEXT page's native ad into [NativeAdCache].
///   * The current page's ad is shown only after a 1.5s delay.
///   * The Next / Start button starts disabled. It enables when either:
///       - the ad has been visible for ≥500ms, or
///       - 5s have passed since mount without the ad loading, in which
///         case the ad slot is hidden and the button becomes enabled.
class _OnboardingScaffold extends StatefulWidget {
  const _OnboardingScaffold({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.myCacheKey,
    required this.nextCacheKey,
    required this.onNext,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final String myCacheKey;
  final String? nextCacheKey;
  final FutureOr<void> Function(BuildContext) onNext;

  @override
  State<_OnboardingScaffold> createState() => _OnboardingScaffoldState();
}

class _OnboardingScaffoldState extends State<_OnboardingScaffold> {
  static const Duration _showDelay = Duration(milliseconds: 1500);
  static const Duration _minAdVisible = Duration(milliseconds: 1000);
  static const Duration _loadTimeout = Duration(seconds: 5);
  static const double _adSlotHeight = 280;

  bool _mountAd = false; // 1.5s delay has elapsed
  bool _adLoaded = false;
  bool _adHidden = false; // dismissed after timeout / failure
  bool _nextEnabled = false;

  Timer? _delayTimer;
  Timer? _timeoutTimer;
  Timer? _minVisibleTimer;

  @override
  void initState() {
    super.initState();

    // Preload the ad for the next screen in the flow.
    final nextKey = widget.nextCacheKey;
    if (nextKey != null) {
      NativeAdCache.preload(
        key: nextKey,
        adUnitId: AdIds.onboardingNative,
        factoryId: AdIds.nativeFactoryId,
      );
    }

    _delayTimer = Timer(_showDelay, () {
      if (!mounted) return;
      setState(() => _mountAd = true);
      // If the cache hit happened before the delay (unlikely since the
      // GlobalNativeAd only mounts now, but safe), kick the visible
      // timer once it reports loaded.
    });

    // Fallback: if the ad isn't loaded within 5s of mount, give up on
    // it — hide the slot and enable Next so the user isn't stuck.
    _timeoutTimer = Timer(_loadTimeout, () {
      if (!mounted || _adLoaded) return;
      setState(() {
        _adHidden = true;
        _nextEnabled = true;
      });
    });
  }

  void _startMinVisibleTimer() {
    _minVisibleTimer?.cancel();
    _minVisibleTimer = Timer(_minAdVisible, () {
      if (!mounted) return;
      setState(() => _nextEnabled = true);
    });
  }

  void _onAdLoaded(String? _) {
    if (!mounted || _adLoaded) return;
    _adLoaded = true;
    _timeoutTimer?.cancel();
    // The ad widget only mounts after the 1.5s delay, so by the time
    // onLoaded fires the ad is already on-screen.
    _startMinVisibleTimer();
  }

  void _onAdFailed(String? _, LoadAdError __) {
    if (!mounted) return;
    _timeoutTimer?.cancel();
    setState(() {
      _adHidden = true;
      _nextEnabled = true;
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _timeoutTimer?.cancel();
    _minVisibleTimer?.cancel();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: 96, color: AppColors.primary),
                    const SizedBox(height: 28),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed:
                      _nextEnabled ? () => widget.onNext(context) : null,
                  child: Text(widget.buttonLabel),
                ),
              ),
            ),
            SizedBox(
              child: (_mountAd && !_adHidden)
                  ? GlobalNativeAd(
                      adUnitId: AdIds.onboardingNative,
                      factoryId: AdIds.nativeFactoryId,
                      adPlacement: widget.myCacheKey,
                      useCache: true,
                      cacheKey: widget.myCacheKey,
                      cacheAutoRefill: false,
                      onLoaded: _onAdLoaded,
                      onLoadFailed: _onAdFailed,
                      content: (ad) => SizedBox(
                        height: _adSlotHeight,
                        child: AdWidget(ad: ad),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
