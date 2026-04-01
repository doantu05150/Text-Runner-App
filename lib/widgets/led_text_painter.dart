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
    final data = pixels!;

    // Collect points into batches for a single draw call each
    final onPoints = <Offset>[];
    final offPoints = <Offset>[];

    for (int row = 0; row < rows; row++) {
      final cy = row * step + step / 2;
      final imgY = (cy - yOffset).round();
      final inYRange = imgY >= 0 && imgY < imageHeight;
      final rowBase = inYRange ? imgY * imageWidth : -1;

      for (int col = 0; col < cols; col++) {
        final cx = col * step + step / 2;
        final center = Offset(cx, cy);

        if (inYRange) {
          final imgX = (cx - offsetX).round();
          if (imgX >= 0 && imgX < imageWidth) {
            final pixelIndex = (rowBase + imgX) * 4;
            if (pixelIndex + 2 < data.length) {
              final brightness = (data[pixelIndex] + data[pixelIndex + 1] + data[pixelIndex + 2]);
              if (brightness > 240) { // ~80 * 3
                onPoints.add(center);
                continue;
              }
            }
          }
        }

        offPoints.add(center);
      }
    }

    final dotDiameter = dotSize;

    // Draw off dots — single batch call
    if (offPoints.isNotEmpty) {
      final offPaint = Paint()
        ..color = ledColor.withValues(alpha: 0.08)
        ..strokeWidth = dotDiameter
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(ui.PointMode.points, offPoints, offPaint);
    }

    // Draw on dots — glow layer then crisp layer, each a single batch call
    if (onPoints.isNotEmpty) {
      final glowPaint = Paint()
        ..color = ledColor.withValues(alpha: 0.3)
        ..strokeWidth = dotDiameter * 1.6
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dotSize * 0.8);
      canvas.drawPoints(ui.PointMode.points, onPoints, glowPaint);

      final onPaint = Paint()
        ..color = ledColor
        ..strokeWidth = dotDiameter
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(ui.PointMode.points, onPoints, onPaint);
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
