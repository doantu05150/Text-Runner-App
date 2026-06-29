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
