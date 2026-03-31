import 'package:flutter/material.dart';

class RunScreen extends StatefulWidget {
  final String text;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final Color textColor;
  final Color backgroundColor;
  final double speed;

  const RunScreen({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    this.fontWeight = FontWeight.normal,
    required this.textColor,
    required this.backgroundColor,
    this.speed = 50.0,
  });

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _textWidth = 0;
  double _screenWidth = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    
    // Initialize animation with dummy value, will update after layout
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Calculate dimensions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDimensions();
    });
  }

  void _calculateDimensions() {
    if (!mounted) return;
    
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _screenWidth = renderBox.size.width;
      });
    }
    
    // Calculate text width
    final textSpan = TextSpan(
      text: widget.text,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontFamily: widget.fontFamily,
        fontWeight: widget.fontWeight,
      ),
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
  }

  void _setupAnimation() {
    if (_screenWidth == 0 || _textWidth == 0) return;
    
    // Calculate duration based on speed (pixels per second)
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
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0);
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: RotatedBox(
        quarterTurns: 1,
        child: GestureDetector(
        onDoubleTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: widget.backgroundColor,
          child: _textWidth > 0
              ? AnimatedBuilder(
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
                              style: TextStyle(
                                fontSize: widget.fontSize,
                                fontFamily: widget.fontFamily,
                                fontWeight: widget.fontWeight,
                                color: widget.textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Center(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontFamily: widget.fontFamily,
                      fontWeight: widget.fontWeight,
                      color: widget.textColor,
                    ),
                  ),
                ),
        ),
      ),
      ),
    );
  }
}
