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

    testWidgets('elongates and tints only the active dot', (tester) async {
      await _pump(tester, const OnboardingDots(
        count: 3, activeIndex: 2, activeColor: Color(0xFF13C2C2),
      ));

      // byKey with a shared ValueKey returns every matching widget.
      final dots = tester
          .widgetList<AnimatedContainer>(find.byKey(const ValueKey('onb-dot')))
          .toList();
      expect(dots, hasLength(3));

      double widthOf(AnimatedContainer c) =>
          (c.constraints as BoxConstraints).maxWidth;
      Color colorOf(AnimatedContainer c) =>
          (c.decoration as BoxDecoration).color!;

      // Inactive dots: index 0 and 1.
      for (final i in [0, 1]) {
        expect(widthOf(dots[i]), 7, reason: 'dot $i should be inactive width');
        expect(colorOf(dots[i]), const Color(0xFFD3CFDB),
            reason: 'dot $i should be inactive color');
      }

      // Active dot: index 2.
      expect(widthOf(dots[2]), 18, reason: 'active dot should be elongated');
      expect(colorOf(dots[2]), const Color(0xFF13C2C2),
          reason: 'active dot should use activeColor');
    });
  });

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
}
