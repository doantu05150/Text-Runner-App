// Smoke tests for onboarding building blocks (ad-free, no platform channels).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_runner_app/screens/onboarding_art.dart';

void main() {
  testWidgets('onboarding illustration + dots build together', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: OnboardingArtCustomize(tint: Color(0xFF9B5CFF)),
              ),
              OnboardingDots(
                count: 3,
                activeIndex: 1,
                activeColor: Color(0xFF9B5CFF),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingArtCustomize), findsOneWidget);
    expect(find.byKey(const ValueKey('onb-dot')), findsNWidgets(3));
  });
}
