import 'package:flutter/material.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/action_bar_widget.dart';
import '../models/saved_item.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'Hello, TextRunner!',
  );

  // Settings
  double _fontSize = 36;
  String _fontFamily = 'Roboto';
  Color _textColor = Colors.black;
  Color _backgroundColor = Colors.white;

  // Input height tracking
  double _inputHeight = 0;
  double _maxInputHeight = 0;
  final double _verticalPadding = 24; // 12px top + 12px bottom
  
  bool get _shouldExpandInput => _inputHeight >= _maxInputHeight;

  // Temporary settings for dialog
  late double _tempFontSize;
  late String _tempFontFamily;
  late Color _tempTextColor;
  late Color _tempBackgroundColor;

  final List<double> _fontSizeOptions = [12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 48, 56, 64, 72];
  final List<String> _fontFamilyOptions = [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
    'Helvetica',
    'Comic Sans MS',
  ];

  @override
  void initState() {
    super.initState();
    _tempFontSize = _fontSize;
    _tempFontFamily = _fontFamily;
    _tempTextColor = _textColor;
    _tempBackgroundColor = _backgroundColor;
    _controller.addListener(_onTextChanged);
    // Initial height calculation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateInputHeight();
    });
  }

  void _onTextChanged() {
    _updateInputHeight();
  }

  void _updateInputHeight() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() {
        _inputHeight = _calculateLineHeight() + _verticalPadding;
      });
      return;
    }

    final lineHeight = _calculateLineHeight();
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: _fontSize,
        fontFamily: _fontFamily,
        height: 1.2,
      ),
    );

    // Get available width for input (screen width - body padding - container padding)
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - 48 - 32; // 24*2 body padding + 16*2 container padding

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    textPainter.layout(maxWidth: availableWidth);

    // Calculate number of lines
    final lineCount = textPainter.computeLineMetrics().length;
    final calculatedHeight = (lineCount * lineHeight) + _verticalPadding;

    // Get max available height for input
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final buttonHeight = 56.0; // ElevatedButton with padding
    final bodyPadding = 48.0; // 24 * 2
    final actionBarHeight = 40.0; // Action bar + SizedBox
    final spacing = 24.0;
    _maxInputHeight = screenHeight - appBarHeight - bodyPadding - buttonHeight - spacing - actionBarHeight;

    setState(() {
      _inputHeight = calculatedHeight.clamp(lineHeight + _verticalPadding, _maxInputHeight);
    });
  }

  double _calculateLineHeight() {
    // Line height = fontSize * 1.2 (standard line height multiplier)
    return _fontSize * 1.2;
  }

  Future<void> _saveText() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản trước khi lưu')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedItemsJson = prefs.getStringList('saved_items') ?? [];
    
    final savedItem = SavedItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _controller.text,
      fontSize: _fontSize,
      fontFamily: _fontFamily,
      textColorValue: _textColor.toARGB32(),
      backgroundColorValue: _backgroundColor.toARGB32(),
      createdAt: DateTime.now(),
    );

    savedItemsJson.add(jsonEncode(savedItem.toJson()));
    await prefs.setStringList('saved_items', savedItemsJson);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu văn bản thành công')),
      );
    }
  }

  void _startTextRunner() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập văn bản trước khi chạy')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/run',
      arguments: {
        'text': _controller.text,
        'fontSize': _fontSize,
        'fontFamily': _fontFamily,
        'textColor': _textColor,
        'backgroundColor': _backgroundColor,
        'speed': 150.0, // pixels per second
      },
    );
  }

  void _showSettingsDialog() {
    // Initialize temp values with current settings
    _tempFontSize = _fontSize;
    _tempFontFamily = _fontFamily;
    _tempTextColor = _textColor;
    _tempBackgroundColor = _backgroundColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('Cài đặt'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Size Dropdown
                  Row(
                    children: [
                      const Icon(Icons.format_size, size: 20),
                      const SizedBox(width: 8),
                      const SizedBox(width: 80, child: Text('Cỡ chữ:')),
                      Expanded(
                        child: DropdownButtonFormField<double>(
                          value: _tempFontSize,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: _fontSizeOptions.map((size) => DropdownMenuItem(
                            value: size,
                            child: Text('${size.toInt()}px'),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                _tempFontSize = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Font Family Dropdown
                  Row(
                    children: [
                      const Icon(Icons.font_download, size: 20),
                      const SizedBox(width: 8),
                      const SizedBox(width: 80, child: Text('Font chữ:')),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _tempFontFamily,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: _fontFamilyOptions.map((font) => DropdownMenuItem(
                            value: font,
                            child: Text(font, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                _tempFontFamily = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Text Color Picker
                  Row(
                    children: [
                      const Icon(Icons.palette, size: 20),
                      const SizedBox(width: 8),
                      const SizedBox(width: 80, child: Text('Màu chữ:')),
                      GestureDetector(
                        onTap: () => _showColorPickerInDialog(setDialogState, true),
                        child: Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _tempTextColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Background Color Picker
                  Row(
                    children: [
                      const Icon(Icons.format_color_fill, size: 20),
                      const SizedBox(width: 8),
                      const SizedBox(width: 80, child: Text('Màu nền:')),
                      GestureDetector(
                        onTap: () => _showColorPickerInDialog(setDialogState, false),
                        child: Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _tempBackgroundColor,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fontSize = _tempFontSize;
                    _fontFamily = _tempFontFamily;
                    _textColor = _tempTextColor;
                    _backgroundColor = _tempBackgroundColor;
                  });
                  // Update input height after font size change
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateInputHeight();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showColorPickerInDialog(void Function(void Function()) setDialogState, bool isTextColor) {
    final List<Color> colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTextColor ? 'Chọn màu chữ' : 'Chọn màu nền'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              setDialogState(() {
                if (isTextColor) {
                  _tempTextColor = color;
                } else {
                  _tempBackgroundColor = color;
                }
              });
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Color get _appBarTextColor {
    if (_backgroundColor == Colors.white) return Colors.black;
    return _backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _appBarTextColor),
        title: Text(
          'Text Runner',
          style: TextStyle(color: _appBarTextColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: _appBarTextColor),
            onPressed: () {
              Navigator.pushNamed(context, '/saved');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar - Settings and Save icons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionBarWidget(
                  iconColor: _appBarTextColor,
                  onSettingsPressed: _showSettingsDialog,
                  onSavePressed: _saveText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Input section
            _shouldExpandInput
                ? Expanded(
                    child: TextInputWidget(
                      controller: _controller,
                      fontSize: _fontSize,
                      fontFamily: _fontFamily,
                      textColor: _textColor,
                      inputHeight: _inputHeight,
                      verticalPadding: _verticalPadding,
                      onChanged: _onTextChanged,
                      shouldExpand: true,
                    ),
                  )
                : TextInputWidget(
                    controller: _controller,
                    fontSize: _fontSize,
                    fontFamily: _fontFamily,
                    textColor: _textColor,
                    inputHeight: _inputHeight,
                    verticalPadding: _verticalPadding,
                    onChanged: _onTextChanged,
                    shouldExpand: false,
                  ),
            const SizedBox(height: 24),

            // Play Button
            ElevatedButton.icon(
              onPressed: _startTextRunner,
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'Chạy chữ',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }
}
