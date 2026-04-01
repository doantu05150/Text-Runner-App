import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/display_style.dart';
import '../theme/app_theme.dart';
import '../utils/font_utils.dart';
import 'led_text_painter.dart';

class PreviewRunWidget extends StatefulWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final double speed;
  final DisplayStyle displayStyle;

  const PreviewRunWidget({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    this.fontWeight = FontWeight.normal,
    required this.textColor,
    required this.backgroundColor,
    this.speed = 150.0,
    this.displayStyle = DisplayStyle.normal,
  });

  @override
  State<PreviewRunWidget> createState() => _PreviewRunWidgetState();
}

class _PreviewRunWidgetState extends State<PreviewRunWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;

  double _previewWidth = 0;
  double _scale = 1.0;
  double _textWidth = 0;

  // LED pixel data
  Uint8List? _ledPixels;
  int _ledImageWidth = 0;
  int _ledImageHeight = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _controller.forward(from: 0);
      }
    });
  }

  void _rebuildAnimation() {
    if (_previewWidth == 0) return;

    final scaledFontSize = widget.fontSize * _scale;
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(fontSize: scaledFontSize, fontWeight: widget.fontWeight)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    _textWidth = textPainter.size.width;

    final distance = _previewWidth + _textWidth;
    final scaledSpeed = widget.speed * _scale;
    final durationMs = scaledSpeed > 0
        ? (distance / scaledSpeed * 1000).round().clamp(100, 120000)
        : 5000;

    _controller.stop();
    _controller.duration = Duration(milliseconds: durationMs);
    _animation = Tween<double>(begin: -_textWidth, end: _previewWidth)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    _controller.forward(from: 0);

    if (widget.displayStyle == DisplayStyle.led) {
      _renderLedPixels(scaledFontSize);
    } else {
      _ledPixels = null;
    }
  }

  Future<void> _renderLedPixels(double scaledFontSize) async {
    final result = await renderTextToPixels(
      text: widget.text,
      textStyle: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
        fontSize: scaledFontSize,
        fontWeight: widget.fontWeight,
      )),
    );
    if (result != null && mounted) {
      setState(() {
        _ledPixels = result.pixels;
        _ledImageWidth = result.width;
        _ledImageHeight = result.height;
      });
    }
  }

  @override
  void didUpdateWidget(PreviewRunWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.fontSize != widget.fontSize ||
        oldWidget.fontFamily != widget.fontFamily ||
        oldWidget.fontWeight != widget.fontWeight ||
        oldWidget.speed != widget.speed ||
        oldWidget.displayStyle != widget.displayStyle) {
      _rebuildAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final aspectRatio = deviceSize.height / deviceSize.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        final newWidth = constraints.maxWidth;
        if (newWidth != _previewWidth) {
          _previewWidth = newWidth;
          _scale = newWidth / deviceSize.height;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _rebuildAnimation();
          });
        }

        final previewHeight = newWidth / aspectRatio;
        final scaledFontSize = widget.fontSize * _scale;

        return Container(
          width: newWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.hardEdge,
          child: widget.text.isEmpty
              ? const SizedBox()
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final position = _animation?.value ?? -_textWidth;

                    if (widget.displayStyle == DisplayStyle.led) {
                      return CustomPaint(
                        size: Size(newWidth, previewHeight),
                        painter: LedTextPainter(
                          pixels: _ledPixels,
                          imageWidth: _ledImageWidth,
                          imageHeight: _ledImageHeight,
                          ledColor: widget.textColor,
                          backgroundColor: widget.backgroundColor,
                          offsetX: position,
                          dotSize: 1.5,
                          dotSpacing: 1.3,
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Positioned(
                          left: position,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Text(
                              widget.text,
                              style: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
                                fontSize: scaledFontSize,
                                fontWeight: widget.fontWeight,
                                color: widget.textColor,
                              )),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}
