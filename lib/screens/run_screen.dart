import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/display_style.dart';
import '../utils/font_utils.dart';
import '../widgets/led_text_painter.dart';

class RunScreen extends StatefulWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final double speed;
  final DisplayStyle displayStyle;
  final bool blinkText;
  final double blinkSpeed;

  const RunScreen({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    this.fontWeight = FontWeight.normal,
    required this.textColor,
    required this.backgroundColor,
    this.speed = 50.0,
    this.displayStyle = DisplayStyle.normal,
    this.blinkText = false,
    this.blinkSpeed = 500.0,
  });

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _screenWidth = 0;

  // Blink
  AnimationController? _blinkController;

  // LED pixel data
  Uint8List? _ledPixels;
  int _ledImageWidth = 0;
  int _ledImageHeight = 0;

  @override
  void initState() {
    super.initState();

    // Hide status bar and navigation bar (full immersive mode)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    // Keep screen awake
    try {
      WakelockPlus.enable();
    } catch (_) {}

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.blinkText) {
      _blinkController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.blinkSpeed.round()),
      )..repeat(reverse: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDimensions();
    });
  }

  void _calculateDimensions() {
    if (!mounted) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _screenWidth = renderBox.size.height;
      });
    }

    final textSpan = TextSpan(
      text: widget.text,
      style: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
      )),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    setState(() {
      _textWidth = textPainter.size.width;
      _setupAnimation();
    });

    if (widget.displayStyle == DisplayStyle.led) {
      _renderLedPixels();
    }
  }

  Future<void> _renderLedPixels() async {
    final result = await renderTextToPixels(
      text: widget.text,
      textStyle: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
        fontSize: widget.fontSize,
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

  void _setupAnimation() {
    if (_screenWidth == 0 || _textWidth == 0) return;

    final distance = _screenWidth + _textWidth;
    final durationInSeconds = distance / widget.speed;

    _controller.duration = Duration(
      milliseconds: (durationInSeconds * 1000).round(),
    );

    _animation = Tween<double>(
      begin: -_textWidth,
      end: _screenWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    // Restore system UI and allow screen to turn off
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    try {
      WakelockPlus.disable();
    } catch (_) {}
    _blinkController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildNormalText() {
    if (_textWidth <= 0) {
      return Center(
        child: Text(
          widget.text,
          style: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.textColor,
          )),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              left: _animation.value,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  widget.text,
                  style: googleFontStyle(widget.fontFamily, baseStyle: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    color: widget.textColor,
                  )),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLedText() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: LedTextPainter(
            pixels: _ledPixels,
            imageWidth: _ledImageWidth,
            imageHeight: _ledImageHeight,
            ledColor: widget.textColor,
            backgroundColor: widget.backgroundColor,
            offsetX: _animation.value,
            dotSize: _ledDotSize(),
            dotSpacing: 1.3,
          ),
        );
      },
    );
  }

  double _ledDotSize() {
    if (widget.fontSize <= 80) return 2.5;
    if (widget.fontSize <= 120) return 3.0;
    if (widget.fontSize <= 160) return 3.5;
    return 4.0;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.displayStyle == DisplayStyle.led
        ? _buildLedText()
        : _buildNormalText();

    if (_blinkController != null) {
      content = FadeTransition(
        opacity: _blinkController!,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: RotatedBox(
        quarterTurns: 1,
        child: GestureDetector(
          onDoubleTap: () => Navigator.pop(context),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: widget.displayStyle == DisplayStyle.led
                ? Colors.transparent
                : widget.backgroundColor,
            child: content,
          ),
        ),
      ),
    );
  }
}
