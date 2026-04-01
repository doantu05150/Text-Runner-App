import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Returns a [TextStyle] for the given Google Fonts family name.
/// Merges with [baseStyle] so callers can set fontSize, color, etc.
TextStyle googleFontStyle(String fontFamily, {TextStyle? baseStyle}) {
  final style = baseStyle ?? const TextStyle();
  try {
    return GoogleFonts.getFont(fontFamily, textStyle: style);
  } catch (_) {
    // Fallback if the font name isn't recognized
    return style;
  }
}
