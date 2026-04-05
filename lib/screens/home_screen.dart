import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/font_utils.dart';
import '../widgets/text_input_widget.dart';
import '../widgets/action_bar_widget.dart';
import '../widgets/preview_run_widget.dart';
import '../widgets/app_button.dart';
import '../models/saved_item.dart';
import '../models/display_style.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'Hello, GlowTextify!',
  );

  // Settings
  double _fontSize = 80;
  String _fontFamily = 'Orbitron';
  FontWeight _fontWeight = FontWeight.w700;
  Color _textColor = Colors.pink;
  Color _backgroundColor = AppColors.bgMain;
  double _speed = 250.0;
  DisplayStyle _displayStyle = DisplayStyle.normal;

  static const double _inputFontSize = 18.0;
  static const double _minInputHeight = 56.0;
  static const double _verticalPadding = 34.0; // 16*2 contentPadding + 1*2 border

  // Input height
  double _inputHeight = _minInputHeight;

  // Preview (debounced)
  String _previewText = 'Hello, GlowTextify!';
  Timer? _debounceTimer;

  // Temporary settings for dialog
  late double _tempFontSize;
  late String _tempFontFamily;
  late FontWeight _tempFontWeight;
  late Color _tempTextColor;
  late Color _tempBackgroundColor;
  late double _tempSpeed;
  late DisplayStyle _tempDisplayStyle;

  final List<double> _fontSizeOptions = List.generate(
    ((240 - 56) ~/ 4) + 1,
    (i) => (56 + i * 4).toDouble(),
  );

  static const _fontWeightOptions = [
    (label: 'Thin', weight: FontWeight.w100),
    (label: 'Light', weight: FontWeight.w300),
    (label: 'Regular', weight: FontWeight.w400),
    (label: 'Medium', weight: FontWeight.w500),
    (label: 'Bold', weight: FontWeight.w700),
    (label: 'Black', weight: FontWeight.w900),
  ];

  final List<String> _fontFamilyOptions = [
    'Roboto',
    'Press Start 2P',
    'VT323',
    'Silkscreen',
    'DotGothic16',
    'Share Tech Mono',
    'Orbitron',
    'Electrolize',
    'Audiowide',
    'Russo One',
  ];

  @override
  void initState() {
    super.initState();
    _tempFontSize = _fontSize;
    _tempFontFamily = _fontFamily;
    _tempFontWeight = _fontWeight;
    _tempTextColor = _textColor;
    _tempBackgroundColor = _backgroundColor;
    _tempSpeed = _speed;
    _tempDisplayStyle = _displayStyle;
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateInputHeight());
  }

  void _onTextChanged() {
    _updateInputHeight();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _previewText = _controller.text);
    });
  }

  void _updateInputHeight() {
    final text = _controller.text;
    if (text.isEmpty) {
      setState(() => _inputHeight = _minInputHeight);
      return;
    }

    final size = MediaQuery.of(context).size;
    final availableWidth = size.width - 40 - 32; // body + container padding

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: _inputFontSize, height: 1.2),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: availableWidth);

    final lineCount = textPainter.computeLineMetrics().length;
    final contentHeight = (lineCount * _inputFontSize * 1.2) + _verticalPadding;

    setState(() {
      _inputHeight = contentHeight.clamp(
        _minInputHeight,
        _calculateMaxInputHeight().clamp(_minInputHeight, double.infinity),
      );
    });
  }

  double _calculateMaxInputHeight() {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final previewHeight = (size.width - 40) * size.width / size.height;
    return size.height
        - (kToolbarHeight + topPadding) // app bar
        - 8.0  // body top padding
        - 20.0 // body bottom padding
        - 40.0 // action bar
        - 12.0 // gap after action bar
        - previewHeight
        - 12.0 // gap after preview
        - 16.0 // gap after input
        - 56.0; // play button
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
      fontWeightValue: _fontWeight.value,
      textColorValue: _textColor.toARGB32(),
      backgroundColorValue: _backgroundColor.toARGB32(),
      speed: _speed,
      displayStyle: _displayStyle.name,
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
        'fontWeight': _fontWeight,
        'speed': _speed,
        'displayStyle': _displayStyle,
      },
    );
  }

  void _showSettingsDialog() {
    // Initialize temp values with current settings
    _tempFontSize = _fontSize;
    _tempFontFamily = _fontFamily;
    _tempFontWeight = _fontWeight;
    _tempTextColor = _textColor;
    _tempBackgroundColor = _backgroundColor;
    _tempSpeed = _speed;
    _tempDisplayStyle = _displayStyle;

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
                  // Display Style
                  _buildSettingRow(
                    icon: Icons.grid_view_rounded,
                    label: 'Kiểu hiển thị',
                    child: _buildDropdown<DisplayStyle>(
                      value: _tempDisplayStyle,
                      items: const [
                        DropdownMenuItem(
                          value: DisplayStyle.normal,
                          child: Text('Bình thường', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                        DropdownMenuItem(
                          value: DisplayStyle.led,
                          child: Text('LED', style: TextStyle(color: AppColors.textPrimary)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setDialogState(() => _tempDisplayStyle = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        child: Text(font, style: googleFontStyle(font, baseStyle: const TextStyle(color: AppColors.textPrimary)), overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => _tempFontFamily = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Font Weight
                  _buildSettingRow(
                    icon: Icons.format_bold_rounded,
                    label: 'Độ đậm',
                    child: _buildDropdown<FontWeight>(
                      value: _tempFontWeight,
                      items: _fontWeightOptions.map((opt) => DropdownMenuItem(
                        value: opt.weight,
                        child: Text(opt.label, style: const TextStyle(color: AppColors.textPrimary)),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => _tempFontWeight = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Speed
                  _buildSettingRow(
                    icon: Icons.speed_rounded,
                    label: 'Tốc độ',
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.primary,
                              overlayColor: AppColors.primarySoft,
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: _tempSpeed,
                              min: 50,
                              max: 600,
                              divisions: (600 - 50) ~/ 10,
                              onChanged: (value) => setDialogState(() => _tempSpeed = value),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${_tempSpeed.round()}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
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
                    _fontWeight = _tempFontWeight;
                    _textColor = _tempTextColor;
                    _backgroundColor = _tempBackgroundColor;
                    _speed = _tempSpeed;
                    _displayStyle = _tempDisplayStyle;
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

  Widget _buildQuickTheme({required String label, required Color bgColor, required Color textColor}) {
    final isSelected = _backgroundColor.toARGB32() == bgColor.toARGB32() &&
        _textColor.toARGB32() == textColor.toARGB32() &&
        _displayStyle == DisplayStyle.led;
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = bgColor;
          _textColor = textColor;
          _displayStyle = DisplayStyle.led;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
        titleSpacing: 20,
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
              'GlowTextify LED',
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
          const SizedBox(width: 20),
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
            const SizedBox(height: 12),
            // Preview
            PreviewRunWidget(
              text: _previewText,
              fontSize: _fontSize,
              fontFamily: _fontFamily,
              fontWeight: _fontWeight,
              textColor: _textColor,
              backgroundColor: _backgroundColor,
              speed: _speed,
              displayStyle: _displayStyle,
            ),
            const SizedBox(height: 12),
            // Quick Themes
            LayoutBuilder(builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12 * 3) / 4;
              return GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: itemWidth / 60,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickTheme(
                  label: 'Textify',
                  bgColor: Colors.black,
                  textColor: Colors.pink,
                ),
                _buildQuickTheme(
                  label: 'Glow',
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                ),
                _buildQuickTheme(
                  label: 'LED',
                  bgColor: Colors.red,
                  textColor: Colors.white,
                ),
                _buildQuickTheme(
                  label: 'App',
                  bgColor: Colors.greenAccent,
                  textColor: Colors.black,
                ),
              ],
              );
            }),
            const SizedBox(height: 12),
            // Input section
            TextInputWidget(
              controller: _controller,
              fontSize: _inputFontSize,
              fontFamily: _fontFamily,
              textColor: AppColors.textPrimary,
              inputHeight: _inputHeight,
              verticalPadding: _verticalPadding,
              onChanged: _onTextChanged,
              shouldExpand: false,
            ),
            const SizedBox(height: 16),

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
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }
}
