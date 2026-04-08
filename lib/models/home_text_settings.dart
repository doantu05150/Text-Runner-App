import 'package:flutter/material.dart';
import 'display_style.dart';

/// Bundle of text-styling values configured on the home screen and
/// edited via the settings dialog.
class HomeTextSettings {
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final double speed;
  final DisplayStyle displayStyle;
  final bool blinkText;
  final double blinkSpeed;

  const HomeTextSettings({
    required this.fontSize,
    required this.fontFamily,
    required this.fontWeight,
    required this.textColor,
    required this.backgroundColor,
    required this.speed,
    required this.displayStyle,
    required this.blinkText,
    required this.blinkSpeed,
  });

  HomeTextSettings copyWith({
    double? fontSize,
    String? fontFamily,
    FontWeight? fontWeight,
    Color? textColor,
    Color? backgroundColor,
    double? speed,
    DisplayStyle? displayStyle,
    bool? blinkText,
    double? blinkSpeed,
  }) {
    return HomeTextSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      speed: speed ?? this.speed,
      displayStyle: displayStyle ?? this.displayStyle,
      blinkText: blinkText ?? this.blinkText,
      blinkSpeed: blinkSpeed ?? this.blinkSpeed,
    );
  }
}
