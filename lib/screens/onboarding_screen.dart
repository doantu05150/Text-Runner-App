import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ads/ad_ids.dart';
import '../ads/global_native_ad.dart';
import '../ads/native_ad_cache.dart';
import 'onboarding_art.dart';
const String _firstLaunchDoneKey = 'app.first_launch_done';

/// Fixed bright palette for onboarding (independent of app dark/light theme).
class _OnbStyle {
  const _OnbStyle(this.gradient, this.accent);
  final List<Color> gradient;
  final Color accent;
}

const _onbPage1Style =
    _OnbStyle([Color(0xFFFF8A4C), Color(0xFFFF5E7E)], Color(0xFFFF5E7E));
const _onbPage2Style =
    _OnbStyle([Color(0xFF9B5CFF), Color(0xFFFF6FD8)], Color(0xFF9B5CFF));
const _onbPage3Style =
    _OnbStyle([Color(0xFF13C2C2), Color(0xFF3BD17A)], Color(0xFF13C2C2));

const _onbPageBg = Color(0xFFFFFFFF);
const _onbTitleColor = Color(0xFF23202B);
const _onbBodyColor = Color(0xFF5C5866);

/// Screen 1 of the first-run tour: "easy to use".
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      title: 'Easy to use',
      description:
          'Type your message and tap Play — that\'s it. GlowTextify turns '
          'your phone into a big, bright scrolling display in one tap.',
      buttonLabel: 'Next',
      myCacheKey: 'onb_native_1',
      nextCacheKey: 'onb_native_2',
      gradientColors: _onbPage1Style.gradient,
      accent: _onbPage1Style.accent,
      illustration: OnboardingArtEasy(tint: _onbPage1Style.accent),
      pageIndex: 0,
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
      title: 'Make it yours',
      description:
          'Pick colors, backgrounds, fonts, speed and effects — tailor '
          'every detail to match the vibe you want.',
      buttonLabel: 'Next',
      myCacheKey: 'onb_native_2',
      nextCacheKey: 'onb_native_3',
      gradientColors: _onbPage2Style.gradient,
      accent: _onbPage2Style.accent,
      illustration: OnboardingArtCustomize(tint: _onbPage2Style.accent),
      pageIndex: 1,
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
      title: 'Save your favorites',
      description:
          'Keep the messages you use often in Saved items and recall '
          'them in a single tap whenever you need them.',
      buttonLabel: 'Start',
      myCacheKey: 'onb_native_3',
      nextCacheKey: null,
      gradientColors: _onbPage3Style.gradient,
      accent: _onbPage3Style.accent,
      illustration: OnboardingArtSave(tint: _onbPage3Style.accent),
      pageIndex: 2,
      onNext: (ctx) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_firstLaunchDoneKey, true);
        if (!ctx.mounted) return;
        Navigator.of(ctx).pushReplacementNamed('/');
      },
    );
  }
}

class _OnboardingScaffold extends StatefulWidget {
  const _OnboardingScaffold({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.myCacheKey,
    required this.nextCacheKey,
    required this.gradientColors,
    required this.accent,
    required this.illustration,
    required this.pageIndex,
    required this.onNext,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final String myCacheKey;
  final String? nextCacheKey;
  final List<Color> gradientColors;
  final Color accent;
  final Widget illustration;
  final int pageIndex;
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
    });

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
      backgroundColor: _onbPageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Hero: gradient panel with the illustration.
            Expanded(
              flex: 46,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: widget.illustration,
                ),
              ),
            ),
            // Body: title + description + dots + button.
            Expanded(
              flex: 54,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _onbTitleColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: _onbBodyColor,
                      ),
                    ),
                    const Spacer(),
                    OnboardingDots(
                      count: 3,
                      activeIndex: widget.pageIndex,
                      activeColor: widget.accent,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              widget.accent.withValues(alpha: 0.4),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onPressed:
                            _nextEnabled ? () => widget.onNext(context) : null,
                        child: Text(widget.buttonLabel),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Native ad pinned at the bottom (UNCHANGED behavior).
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
