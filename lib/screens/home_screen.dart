import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/action_bar_widget.dart';
import '../widgets/app_button.dart';
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
  Color _textColor = Colors.white;
  Color _backgroundColor = AppColors.bgMain;

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
        SnackBar(
          content: const Text('Vui lòng nhập văn bản trước khi lưu'),
          backgroundColor: AppColors.bgCard,
        ),
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Đã lưu văn bản thành công'),
            ],
          ),
          backgroundColor: AppColors.bgCard,
        ),
      );
    }
  }

  void _startTextRunner() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập văn bản trước khi chạy'),
          backgroundColor: AppColors.bgCard,
        ),
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
            backgroundColor: AppColors.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cài đặt',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Font Size
                  _buildSettingRow(
                    icon: Icons.format_size_rounded,
                    label: 'Cỡ chữ',
                    child: _buildDropdown<double>(
                      value: _tempFontSize,
                      items: _fontSizeOptions.map((size) => DropdownMenuItem(
                        value: size,
                        child: Text('${size.toInt()}px', style: const TextStyle(color: AppColors.textPrimary)),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => _tempFontSize = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Font Family
                  _buildSettingRow(
                    icon: Icons.font_download_rounded,
                    label: 'Font chữ',
                    child: _buildDropdown<String>(
                      value: _tempFontFamily,
                      items: _fontFamilyOptions.map((font) => DropdownMenuItem(
                        value: font,
                        child: Text(font, style: const TextStyle(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => _tempFontFamily = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text Color
                  _buildSettingRow(
                    icon: Icons.palette_rounded,
                    label: 'Màu chữ',
                    child: _buildColorSwatch(_tempTextColor, () => _showColorPickerInDialog(setDialogState, true)),
                  ),
                  const SizedBox(height: 16),

                  // Background Color
                  _buildSettingRow(
                    icon: Icons.format_color_fill_rounded,
                    label: 'Màu nền',
                    child: _buildColorSwatch(_tempBackgroundColor, () => _showColorPickerInDialog(setDialogState, false)),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              AppButton(
                isPrimary: false,
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 8),
              AppButton(
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

  Widget _buildSettingRow({required IconData icon, required String label, required Widget child}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildDropdown<T>({required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgMain,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.bgCard,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.bgMain,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontFamily: 'monospace'),
            ),
            const Spacer(),
            const Icon(Icons.colorize_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
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

    final currentColor = isTextColor ? _tempTextColor : _tempBackgroundColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          isTextColor ? 'Chọn màu chữ' : 'Chọn màu nền',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((color) {
            final isSelected = color.toARGB32() == currentColor.toARGB32();
            return GestureDetector(
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          AppButton(
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.text_fields_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Text Runner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          AppIconButton(
            icon: Icons.bookmark_rounded,
            onPressed: () => Navigator.pushNamed(context, '/saved'),
            tooltip: 'Đã lưu',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ActionBarWidget(
                  iconColor: AppColors.textSecondary,
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
            const SizedBox(height: 20),

            // Play Button
            AppButton(
              onPressed: _startTextRunner,
              icon: Icons.play_arrow_rounded,
              child: const Text(
                'Chạy chữ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
