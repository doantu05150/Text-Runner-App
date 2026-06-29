# Onboarding Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the plain single-icon onboarding pages with a colorful Direction-B design — a per-page gradient hero containing a code-drawn flat-vector illustration, page-indicator dots, and a full-width pill button — while preserving the existing 3-page flow, copy, routing, and native-ad gating exactly.

**Architecture:** Keep the three `OnboardingPage1/2/3` widgets and the `_OnboardingScaffold` (with all its ad timer/state logic untouched). Refactor the scaffold's `build()` into a new portrait layout that takes per-page visual parameters (gradient colors, accent color, illustration widget, page index). Add a new file `lib/screens/onboarding_art.dart` holding three `CustomPaint` illustration widgets, plus a small reusable page-dots widget. Onboarding uses its own fixed bright palette, independent of the app's dark/light `AppColors`.

**Tech Stack:** Flutter, Dart, `CustomPainter` for illustrations, `TweenAnimationBuilder` for the entrance animation. No new packages, no asset files.

---

## File Structure

- `lib/screens/onboarding_art.dart` — **new**. Three illustration widgets (`OnboardingArtEasy`, `OnboardingArtCustomize`, `OnboardingArtSave`) each backed by a private `CustomPainter`, plus a small `OnboardingDots` widget. All pure (no ad / no SharedPreferences dependency), so they are widget-testable in isolation.
- `lib/screens/onboarding_screen.dart` — **modify**. Add a private palette block (3 gradient/accent triples). Extend `_OnboardingScaffold` with `gradientColors`, `accent`, `illustration`, `pageIndex` fields. Rewrite `build()` for the new layout. Pass the new params from `OnboardingPage1/2/3`. Leave all ad state, timers, and `onNext` callbacks unchanged.
- `test/onboarding_art_test.dart` — **new**. Smoke tests for the illustration widgets and `OnboardingDots`.

Not touched: `lib/main.dart` (routes unchanged), `lib/theme/app_theme.dart`, ad infrastructure.

---

## Task 1: Page-indicator dots widget (TDD)

**Files:**
- Create: `lib/screens/onboarding_art.dart`
- Test: `test/onboarding_art_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/onboarding_art_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_runner_app/screens/onboarding_art.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: child))),
  );
}

void main() {
  group('OnboardingDots', () {
    testWidgets('renders one dot per page count', (tester) async {
      await _pump(tester, const OnboardingDots(
        count: 3, activeIndex: 0, activeColor: Color(0xFFFF5E7E),
      ));
      expect(find.byKey(const ValueKey('onb-dot')), findsNWidgets(3));
    });

    testWidgets('accepts a valid active index without error', (tester) async {
      await _pump(tester, const OnboardingDots(
        count: 3, activeIndex: 2, activeColor: Color(0xFF13C2C2),
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/onboarding_art_test.dart`
Expected: FAIL — `onboarding_art.dart` / `OnboardingDots` does not exist (compile error / "Target of URI doesn't exist").

- [ ] **Step 3: Write minimal implementation**

Create `lib/screens/onboarding_art.dart` with the dots widget:

```dart
import 'package:flutter/material.dart';

/// Row of page-indicator dots; the active one is elongated and colored.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
    required this.activeColor,
  });

  final int count;
  final int activeIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          key: const ValueKey('onb-dot'),
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 7,
          width: active ? 18 : 7,
          decoration: BoxDecoration(
            color: active ? activeColor : const Color(0xFFD3CFDB),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/onboarding_art_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/screens/onboarding_art.dart test/onboarding_art_test.dart
git commit -m "feat: add onboarding page-indicator dots widget"
```

---

## Task 2: Three illustration widgets (TDD smoke tests)

**Files:**
- Modify: `lib/screens/onboarding_art.dart`
- Test: `test/onboarding_art_test.dart`

The three illustrations are flat-vector `CustomPaint` widgets on a transparent
background (the hero gradient shows behind them). Each takes a `Color tint` so
the art can pick up the page accent. Tests are smoke tests: the widget builds
and paints at a fixed size without throwing.

- [ ] **Step 1: Write the failing tests**

Add to `test/onboarding_art_test.dart` inside `main()`:

```dart
  group('illustrations', () {
    Future<void> pumpArt(WidgetTester tester, Widget art) async {
      await _pump(tester, SizedBox(width: 200, height: 200, child: art));
      expect(tester.takeException(), isNull);
    }

    testWidgets('OnboardingArtEasy paints', (tester) async {
      await pumpArt(tester, const OnboardingArtEasy(tint: Color(0xFFFF5E7E)));
      expect(find.byType(OnboardingArtEasy), findsOneWidget);
    });

    testWidgets('OnboardingArtCustomize paints', (tester) async {
      await pumpArt(tester, const OnboardingArtCustomize(tint: Color(0xFF9B5CFF)));
      expect(find.byType(OnboardingArtCustomize), findsOneWidget);
    });

    testWidgets('OnboardingArtSave paints', (tester) async {
      await pumpArt(tester, const OnboardingArtSave(tint: Color(0xFF13C2C2)));
      expect(find.byType(OnboardingArtSave), findsOneWidget);
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/onboarding_art_test.dart`
Expected: FAIL — `OnboardingArtEasy` / `OnboardingArtCustomize` / `OnboardingArtSave` are undefined.

- [ ] **Step 3: Write the implementation**

Append to `lib/screens/onboarding_art.dart`:

```dart
/// Page 1 art: a phone showing glowing scrolling letters + a tap burst.
class OnboardingArtEasy extends StatelessWidget {
  const OnboardingArtEasy({super.key, required this.tint});
  final Color tint;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _EasyPainter(tint), size: Size.infinite);
}

/// Page 2 art: a paint palette with color swatches + a slider.
class OnboardingArtCustomize extends StatelessWidget {
  const OnboardingArtCustomize({super.key, required this.tint});
  final Color tint;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _CustomizePainter(tint), size: Size.infinite);
}

/// Page 3 art: a starred bookmark card with saved chips.
class OnboardingArtSave extends StatelessWidget {
  const OnboardingArtSave({super.key, required this.tint});
  final Color tint;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SavePainter(tint), size: Size.infinite);
}

const _white = Color(0xFFFFFFFF);
Color _glass([double o = 0.22]) => _white.withValues(alpha: o);

class _EasyPainter extends CustomPainter {
  _EasyPainter(this.tint);
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;

    // Phone body (white, rounded), centered, landscape-ish.
    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.62, height: h * 0.40),
      Radius.circular(w * 0.06),
    );
    fill.color = _white;
    canvas.drawRRect(phone, fill);

    // Screen (dark slot) inside the phone.
    final screen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.52), width: w * 0.50, height: h * 0.24),
      Radius.circular(w * 0.03),
    );
    fill.color = const Color(0xFF1A1622);
    canvas.drawRRect(screen, fill);

    // Three glowing "letter" bars scrolling across the screen.
    fill.color = tint;
    for (var i = 0; i < 3; i++) {
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * (0.30 + i * 0.13), h * 0.47, w * 0.06, h * 0.10),
        Radius.circular(w * 0.02),
      );
      canvas.drawRRect(bar, fill);
    }

    // Tap burst (a finger-dot + radiating ticks) at bottom-right.
    final burstC = Offset(w * 0.74, h * 0.74);
    fill.color = tint;
    canvas.drawCircle(burstC, w * 0.045, fill);
    final ray = Paint()
      ..color = tint
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * 1.0472; // 60 degrees
      final from = burstC + Offset(0, 0);
      final to = burstC + Offset(w * 0.08 * _cos(a), w * 0.08 * _sin(a));
      canvas.drawLine(from + Offset(w * 0.06 * _cos(a), w * 0.06 * _sin(a)), to, ray);
    }
  }

  @override
  bool shouldRepaint(covariant _EasyPainter old) => old.tint != tint;
}

class _CustomizePainter extends CustomPainter {
  _CustomizePainter(this.tint);
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;

    // Palette blob (white) with a thumb hole.
    fill.color = _white;
    canvas.drawCircle(Offset(w * 0.46, h * 0.46), w * 0.30, fill);
    fill.color = _glass(0.0); // erase via blend not needed; draw hole as gradient bg color
    // Thumb hole: punch with the page-gradient look by drawing a translucent ring gap.
    final hole = Paint()..color = _glass(0.0);
    canvas.drawCircle(Offset(w * 0.58, h * 0.56), w * 0.07, hole);

    // Four paint dabs around the palette (varied colors for "more colors").
    final dabs = <Color>[
      tint,
      const Color(0xFFFFC24B),
      const Color(0xFF4BC0FF),
      const Color(0xFF7BE08A),
    ];
    final centers = <Offset>[
      Offset(w * 0.34, h * 0.33),
      Offset(w * 0.55, h * 0.31),
      Offset(w * 0.33, h * 0.55),
      Offset(w * 0.48, h * 0.62),
    ];
    for (var i = 0; i < dabs.length; i++) {
      fill.color = dabs[i];
      canvas.drawCircle(centers[i], w * 0.055, fill);
    }

    // A slider below the palette (track + knob) for "speed/effects".
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.80, w * 0.64, h * 0.035),
      Radius.circular(h * 0.02),
    );
    fill.color = _glass(0.45);
    canvas.drawRRect(track, fill);
    fill.color = _white;
    canvas.drawCircle(Offset(w * 0.62, h * 0.817), w * 0.045, fill);
  }

  @override
  bool shouldRepaint(covariant _CustomizePainter old) => old.tint != tint;
}

class _SavePainter extends CustomPainter {
  _SavePainter(this.tint);
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;

    // Two stacked "saved" cards (white), the front one offset.
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.30, w * 0.50, h * 0.16),
      Radius.circular(w * 0.04),
    );
    fill.color = _glass(0.55);
    canvas.drawRRect(back, fill);

    final front = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.50, h * 0.18),
      Radius.circular(w * 0.04),
    );
    fill.color = _white;
    canvas.drawRRect(front, fill);

    // Text lines on the front card.
    fill.color = const Color(0xFFCFC9D9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.53, w * 0.30, h * 0.022),
        Radius.circular(h * 0.02)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.575, w * 0.22, h * 0.022),
        Radius.circular(h * 0.02)),
      fill,
    );

    // A filled star badge (tinted) overlapping the top-right of the front card.
    _drawStar(canvas, Offset(w * 0.68, h * 0.44), w * 0.11, tint);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r * 0.45;
      final a = -1.5708 + i * 0.6283; // start at top, 36deg steps
      final p = c + Offset(radius * _cos(a), radius * _sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SavePainter old) => old.tint != tint;
}
```

The painters above call `_cos(...)` / `_sin(...)`. Define those once, and add
the `dart:math` import, at the **top** of `lib/screens/onboarding_art.dart`.
The full top-of-file header should read:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

double _cos(double a) => math.cos(a);
double _sin(double a) => math.sin(a);
```

There must be exactly one definition of `_cos` and `_sin` in the file (only the
two above) — do not add any other copies at the bottom.

> Implementer note: the goal is recognizable, clean flat shapes — not
> photorealism. If a specific coordinate looks off when you run it, nudge the
> fractions; the tests only assert the widgets paint without throwing.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/onboarding_art_test.dart`
Expected: PASS (5 tests total).

- [ ] **Step 5: Verify analyzer is clean**

Run: `flutter analyze lib/screens/onboarding_art.dart`
Expected: "No issues found!" (fix any unused-import / duplicate-definition warnings before committing).

- [ ] **Step 6: Commit**

```bash
git add lib/screens/onboarding_art.dart test/onboarding_art_test.dart
git commit -m "feat: add code-drawn onboarding illustrations"
```

---

## Task 3: Onboarding palette + scaffold layout rewrite

**Files:**
- Modify: `lib/screens/onboarding_screen.dart`

Add per-page visual params to `_OnboardingScaffold` and rewrite its `build()`.
**Do not change** any ad state, timers, cache-key logic, or `onNext`/first-launch
behavior — only the visual tree and the new fields.

- [ ] **Step 1: Add the imports and palette block**

At the top of `lib/screens/onboarding_screen.dart`, add the art import (keep existing imports):

```dart
import 'onboarding_art.dart';
```

Below the existing `_firstLaunchDoneKey` const, add a private palette holder:

```dart
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
```

- [ ] **Step 2: Extend `_OnboardingScaffold` fields**

Add these fields to `_OnboardingScaffold` and its constructor (alongside the existing ones):

```dart
  final List<Color> gradientColors;
  final Color accent;
  final Widget illustration;
  final int pageIndex;
```

Constructor params (add as `required`):

```dart
    required this.gradientColors,
    required this.accent,
    required this.illustration,
    required this.pageIndex,
```

- [ ] **Step 3: Update the three page classes to pass the new params**

In `OnboardingPage1.build()`'s `_OnboardingScaffold(...)`, add:

```dart
      gradientColors: _onbPage1Style.gradient,
      accent: _onbPage1Style.accent,
      illustration: OnboardingArtEasy(tint: _onbPage1Style.accent),
      pageIndex: 0,
```

In `OnboardingPage2.build()`:

```dart
      gradientColors: _onbPage2Style.gradient,
      accent: _onbPage2Style.accent,
      illustration: OnboardingArtCustomize(tint: _onbPage2Style.accent),
      pageIndex: 1,
```

In `OnboardingPage3.build()`:

```dart
      gradientColors: _onbPage3Style.gradient,
      accent: _onbPage3Style.accent,
      illustration: OnboardingArtSave(tint: _onbPage3Style.accent),
      pageIndex: 2,
```

(Leave `icon:` in place for now if present; it becomes unused and is removed in
Step 5. Do not remove the `title`, `description`, `buttonLabel`, cache-key, or
`onNext` args.)

- [ ] **Step 4: Rewrite `_OnboardingScaffoldState.build()`**

Replace the entire `build()` method body with the new layout. The ad `SizedBox`
subtree (lines mounting `GlobalNativeAd` with `_mountAd && !_adHidden`) is
reused verbatim — only its surrounding layout changes:

```dart
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
            // Native ad pinned at the bottom (unchanged behavior).
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
```

- [ ] **Step 5: Remove the now-unused `icon` field**

Delete the `final IconData icon;` field, its constructor param `required this.icon,`,
and the `icon:` argument in all three page classes (it is no longer referenced).
The old `Icon(widget.icon, ...)` usage was removed in Step 4.

- [ ] **Step 6: Verify analyzer is clean**

Run: `flutter analyze lib/screens/onboarding_screen.dart`
Expected: "No issues found!" (no unused `icon`, no unused `AppColors`/`AppTheme`
import — remove the `app_theme.dart` import if it is now unused).

- [ ] **Step 7: Commit**

```bash
git add lib/screens/onboarding_screen.dart
git commit -m "feat: redesign onboarding with gradient hero + illustrations"
```

---

## Task 4: Entrance animation

**Files:**
- Modify: `lib/screens/onboarding_screen.dart`

Add a short fade + upward-slide entrance for the illustration and the
title/description when each page mounts. Illustration leads slightly.

- [ ] **Step 1: Add an animation flag to the state**

In `_OnboardingScaffoldState`, add a field:

```dart
  bool _entered = false;
```

In `initState()`, after the existing timer setup, schedule the entrance on the
next frame:

```dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _entered = true);
    });
```

(Add `import 'package:flutter/scheduler.dart';` only if `WidgetsBinding` is not
already resolvable — it is exported by `material.dart`, so no new import is
expected.)

- [ ] **Step 2: Wrap the illustration with an animated transition**

In `build()`, replace `child: widget.illustration,` (inside the hero `Padding`)
with:

```dart
                  child: AnimatedSlide(
                    offset: _entered ? Offset.zero : const Offset(0, 0.08),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _entered ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: widget.illustration,
                    ),
                  ),
```

- [ ] **Step 3: Wrap the title+description block with a slightly delayed fade**

Wrap the `Text(widget.title…)` + `SizedBox` + `Text(widget.description…)` group
in an `AnimatedOpacity` + `AnimatedSlide` (slightly longer duration so it trails
the illustration). Replace those three widgets with a single child:

```dart
                    AnimatedSlide(
                      offset: _entered ? Offset.zero : const Offset(0, 0.12),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _entered ? 1 : 0,
                        duration: const Duration(milliseconds: 650),
                        child: Column(
                          children: [
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
                          ],
                        ),
                      ),
                    ),
```

- [ ] **Step 4: Verify analyzer is clean**

Run: `flutter analyze lib/screens/onboarding_screen.dart`
Expected: "No issues found!"

- [ ] **Step 5: Commit**

```bash
git add lib/screens/onboarding_screen.dart
git commit -m "feat: animate onboarding hero and text on entrance"
```

---

## Task 5: Full verification

**Files:** none (verification only)

- [ ] **Step 1: Analyzer + tests across the project**

Run: `flutter analyze`
Expected: "No issues found!"

Run: `flutter test`
Expected: all tests pass (includes `test/onboarding_art_test.dart`).

- [ ] **Step 2: Manual run on a device/emulator**

To force the first-run flow, clear the saved flag (uninstall/reinstall the app,
or clear app data) so `app.first_launch_done` is unset, then:

Run: `flutter run`

Verify on each of the 3 pages:
- The gradient hero shows the page's colors (coral/pink → purple/magenta → teal/green).
- The illustration renders cleanly inside the hero.
- Title + description are centered and readable on a white background.
- The 3 page dots show the correct active page (elongated, accent-colored).
- The illustration and text fade/slide in on page load.
- The **Next** button stays disabled until the ad gate allows it (same as before),
  then advances; page 3's **Start** writes the flag and lands on the home screen.
- The native ad still appears pinned at the bottom.
- No layout overflow with the ad present.

- [ ] **Step 3: Final confirmation**

Confirm the flow, copy, routes, and ad behavior are unchanged from before — only
the visuals differ.
