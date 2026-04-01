import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LedTextPainter extends CustomPainter {
  final Uint8List? pixels;
  final int imageWidth;
  final int imageHeight;
  final Color ledColor;
  final Color backgroundColor;
  final double offsetX;
  final double dotSize;
  final double dotSpacing;

  LedTextPainter({
    required this.pixels,
    required this.imageWidth,
    required this.imageHeight,
    required this.ledColor,
    required this.backgroundColor,
    required this.offsetX,
    this.dotSize = 3.0,
    this.dotSpacing = 1.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    if (pixels == null || imageWidth <= 0 || imageHeight <= 0) return;

    final step = dotSize * dotSpacing;
    final cols = (size.width / step).ceil() + 1;
    final rows = (size.height / step).ceil();

    final yOffset = (size.height - imageHeight) / 2;

    final offPaint = Paint()..color = ledColor.withValues(alpha: 0.08);
    final onPaint = Paint()..color = ledColor;
    final glowPaint = Paint()
      ..color = ledColor.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, dotSize * 0.8);

    final dotRadius = dotSize / 2;
    final data = pixels!;

    for (int row = 0; row < rows; row++) {
      final cy = row * step + step / 2;
      final imgY = (cy - yOffset).round();

      for (int col = 0; col < cols; col++) {
        final cx = col * step + step / 2;
        final imgX = (cx - offsetX).round();
        final center = Offset(cx, cy);

        if (imgX >= 0 && imgX < imageWidth && imgY >= 0 && imgY < imageHeight) {
          final pixelIndex = (imgY * imageWidth + imgX) * 4;
          if (pixelIndex >= 0 && pixelIndex + 2 < data.length) {
            final r = data[pixelIndex];
            final g = data[pixelIndex + 1];
            final b = data[pixelIndex + 2];
            final brightness = (r + g + b) / 3;

            if (brightness > 80) {
              canvas.drawCircle(center, dotRadius * 1.6, glowPaint);
              canvas.drawCircle(center, dotRadius, onPaint);
              continue;
            }
          }
        }

        canvas.drawCircle(center, dotRadius, offPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LedTextPainter oldDelegate) {
    return oldDelegate.offsetX != offsetX ||
        oldDelegate.pixels != pixels ||
        oldDelegate.ledColor != ledColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.dotSize != dotSize;
  }
}

/// Renders text to RGBA pixel data asynchronously.
Future<({Uint8List pixels, int width, int height})?> renderTextToPixels({
  required String text,
  required TextStyle textStyle,
}) async {
  final textSpan = TextSpan(text: text, style: textStyle.copyWith(color: Colors.white));
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  )..layout();

  final w = textPainter.size.width.ceil();
  final h = textPainter.size.height.ceil();
  if (w <= 0 || h <= 0) return null;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), Paint()..color = Colors.black);
  textPainter.paint(canvas, Offset.zero);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(w, h);

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();

  if (byteData == null) return null;

  return (
    pixels: byteData.buffer.asUint8List(),
    width: w,
    height: h,
  );
}
