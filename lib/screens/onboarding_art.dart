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
