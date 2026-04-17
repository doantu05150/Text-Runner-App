import 'package:flutter/material.dart';
import '../models/display_style.dart';
import '../theme/app_theme.dart';

/// One preset entry shown in [QuickThemesGrid].
class QuickTheme {
  const QuickTheme({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.blinkText = false,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool blinkText;
}

/// 4-column grid of quick LED color presets.
///
/// Selecting a tile reports the chosen [QuickTheme] via [onSelected];
/// it's the parent's job to apply the colors and switch the display
/// style to [DisplayStyle.led].
class QuickThemesGrid extends StatelessWidget {
  const QuickThemesGrid({
    super.key,
    required this.themes,
    required this.currentTextColor,
    required this.currentBackgroundColor,
    required this.currentDisplayStyle,
    required this.onSelected,
  });

  final List<QuickTheme> themes;
  final Color currentTextColor;
  final Color currentBackgroundColor;
  final DisplayStyle currentDisplayStyle;
  final ValueChanged<QuickTheme> onSelected;

  static const List<QuickTheme> defaultThemes = [
    QuickTheme(
      label: 'Glow',
      backgroundColor: Colors.black,
      textColor: Colors.pink,
    ),
    QuickTheme(
      label: 'Textify',
      backgroundColor: Colors.white,
      textColor: Colors.pink,
    ),
    QuickTheme(
      label: 'LED',
      backgroundColor: Colors.red,
      textColor: Colors.black,
      blinkText: true,
    ),
    QuickTheme(
      label: 'App',
      backgroundColor: Colors.greenAccent,
      textColor: Colors.black,
      blinkText: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - 12 * 3) / 4;
      return GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: itemWidth / 60,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: themes.map((theme) {
          final isSelected =
              currentBackgroundColor.toARGB32() == theme.backgroundColor.toARGB32() &&
                  currentTextColor.toARGB32() == theme.textColor.toARGB32() &&
                  currentDisplayStyle == DisplayStyle.led;
          return _QuickThemeTile(
            theme: theme,
            isSelected: isSelected,
            onTap: () => onSelected(theme),
          );
        }).toList(),
      );
    });
  }
}

class _QuickThemeTile extends StatelessWidget {
  const _QuickThemeTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  final QuickTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            theme.label,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
