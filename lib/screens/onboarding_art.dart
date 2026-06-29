import 'dart:math' as math;
import 'package:flutter/material.dart';

double _cos(double a) => math.cos(a);
double _sin(double a) => math.sin(a);

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
        // Each keyed dot is wrapped in an unkeyed Padding so the keyed
        // widgets are not direct siblings of the Row (which would trigger
        // Flutter's duplicate-key assertion), while still being findable
        // by ValueKey('onb-dot') in tests.
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            key: const ValueKey('onb-dot'),
            duration: const Duration(milliseconds: 250),
            height: 7,
            width: active ? 18 : 7,
            decoration: BoxDecoration(
              color: active ? activeColor : const Color(0xFFD3CFDB),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

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

    // Phone body (white, rounded).
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

    // Tap burst (a dot + radiating ticks) at bottom-right.
    final burstC = Offset(w * 0.74, h * 0.74);
    fill.color = tint;
    canvas.drawCircle(burstC, w * 0.045, fill);
    final ray = Paint()
      ..color = tint
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * 1.0472; // 60 degrees
      final to = burstC + Offset(w * 0.08 * _cos(a), w * 0.08 * _sin(a));
      canvas.drawLine(burstC + Offset(w * 0.06 * _cos(a), w * 0.06 * _sin(a)), to, ray);
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

    // Palette blob (white).
    fill.color = _white;
    canvas.drawCircle(Offset(w * 0.46, h * 0.46), w * 0.30, fill);

    // Four paint dabs around the palette (varied colors).
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

    // A slider below the palette (track + knob).
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

    // Back card.
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.30, w * 0.50, h * 0.16),
      Radius.circular(w * 0.04),
    );
    fill.color = _glass(0.55);
    canvas.drawRRect(back, fill);

    // Front card (white).
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

    // A filled star badge (tinted) overlapping the front card.
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
