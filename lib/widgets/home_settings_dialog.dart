import 'package:flutter/material.dart';
import '../models/display_style.dart';
import '../models/home_text_settings.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/font_utils.dart';
import 'app_button.dart';

/// Opens the home-screen text settings dialog.
///
/// Returns the new [HomeTextSettings] when the user taps Save, or `null`
/// if the dialog is dismissed.
Future<HomeTextSettings?> showHomeSettingsDialog(
  BuildContext context, {
  required HomeTextSettings current,
}) {
  return showDialog<HomeTextSettings>(
    context: context,
    builder: (context) => _HomeSettingsDialog(initial: current),
  );
}

const _fontSizeOptions = <double>[
  56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116,
  120, 124, 128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172,
  176, 180, 184, 188, 192, 196, 200, 204, 208, 212, 216, 220, 224, 228,
  232, 236, 240,
];

const _fontWeightOptions = [
  (label: 'Thin', weight: FontWeight.w100),
  (label: 'Light', weight: FontWeight.w300),
  (label: 'Regular', weight: FontWeight.w400),
  (label: 'Medium', weight: FontWeight.w500),
  (label: 'Bold', weight: FontWeight.w700),
  (label: 'Black', weight: FontWeight.w900),
];

const _fontFamilyOptions = <String>[
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

class _HomeSettingsDialog extends StatefulWidget {
  const _HomeSettingsDialog({required this.initial});

  final HomeTextSettings initial;

  @override
  State<_HomeSettingsDialog> createState() => _HomeSettingsDialogState();
}

class _HomeSettingsDialogState extends State<_HomeSettingsDialog> {
  late double _fontSize = widget.initial.fontSize;
  late String _fontFamily = widget.initial.fontFamily;
  late FontWeight _fontWeight = widget.initial.fontWeight;
  late Color _textColor = widget.initial.textColor;
  late Color _backgroundColor = widget.initial.backgroundColor;
  late double _speed = widget.initial.speed;
  late DisplayStyle _displayStyle = widget.initial.displayStyle;
  late bool _blinkText = widget.initial.blinkText;
  late double _blinkSpeed = widget.initial.blinkSpeed;

  @override
  Widget build(BuildContext context) {
    final t = LocaleController.instance.strings;
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            t.settings,
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
            _settingRow(
              icon: Icons.grid_view_rounded,
              label: t.displayStyle,
              child: _dropdown<DisplayStyle>(
                value: _displayStyle,
                items: [
                  DropdownMenuItem(
                    value: DisplayStyle.normal,
                    child: Text(t.normal, style: TextStyle(color: AppColors.textPrimary)),
                  ),
                  DropdownMenuItem(
                    value: DisplayStyle.led,
                    child: Text('LED', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _displayStyle = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.format_size_rounded,
              label: t.fontSize,
              child: _dropdown<double>(
                value: _fontSize,
                items: _fontSizeOptions
                    .map((size) => DropdownMenuItem(
                          value: size,
                          child: Text('${size.toInt()}px',
                              style: TextStyle(color: AppColors.textPrimary)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fontSize = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.font_download_rounded,
              label: t.fontFamily,
              child: _dropdown<String>(
                value: _fontFamily,
                items: _fontFamilyOptions
                    .map((font) => DropdownMenuItem(
                          value: font,
                          child: Text(
                            font,
                            style: googleFontStyle(font,
                                baseStyle: TextStyle(color: AppColors.textPrimary)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fontFamily = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.format_bold_rounded,
              label: t.fontWeight,
              child: _dropdown<FontWeight>(
                value: _fontWeight,
                items: _fontWeightOptions
                    .map((opt) => DropdownMenuItem(
                          value: opt.weight,
                          child: Text(opt.label,
                              style: TextStyle(color: AppColors.textPrimary)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _fontWeight = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.speed_rounded,
              label: t.speed,
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
                        value: _speed,
                        min: 50,
                        max: 600,
                        divisions: (600 - 50) ~/ 10,
                        onChanged: (value) => setState(() => _speed = value),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_speed.round()}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.palette_rounded,
              label: t.textColor,
              child: _colorSwatch(_textColor, () => _pickColor(isTextColor: true)),
            ),
            const SizedBox(height: 8),
            _settingRow(
              icon: Icons.format_color_fill_rounded,
              label: t.backgroundColor,
              child: _colorSwatch(_backgroundColor, () => _pickColor(isTextColor: false)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.flare_rounded, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(t.blink,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                SizedBox(
                  height: 32,
                  child: FittedBox(
                    child: Switch(
                      value: _blinkText,
                      activeThumbColor: AppColors.primary,
                      onChanged: (value) => setState(() => _blinkText = value),
                    ),
                  ),
                ),
                if (_blinkText) ...[
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
                        value: _blinkSpeed,
                        min: 100,
                        max: 1000,
                        divisions: 18,
                        onChanged: (value) => setState(() => _blinkSpeed = value),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${_blinkSpeed.round()}',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        AppButton(
          isPrimary: false,
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        const SizedBox(width: 8),
        AppButton(
          onPressed: () {
            Navigator.pop(
              context,
              HomeTextSettings(
                fontSize: _fontSize,
                fontFamily: _fontFamily,
                fontWeight: _fontWeight,
                textColor: _textColor,
                backgroundColor: _backgroundColor,
                speed: _speed,
                displayStyle: _displayStyle,
                blinkText: _blinkText,
                blinkSpeed: _blinkSpeed,
              ),
            );
          },
          child: Text(t.save),
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
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
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
        ),
      ),
    );
  }

  Widget _colorSwatch(Color color, VoidCallback onTap) {
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            Icon(Icons.colorize_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _pickColor({required bool isTextColor}) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        isTextColor: isTextColor,
        currentColor: isTextColor ? _textColor : _backgroundColor,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isTextColor) {
        _textColor = picked;
      } else {
        _backgroundColor = picked;
      }
    });
  }
}

class _ColorPickerDialog extends StatelessWidget {
  const _ColorPickerDialog({
    required this.isTextColor,
    required this.currentColor,
  });

  final bool isTextColor;
  final Color currentColor;

  static const _colors = <Color>[
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

  @override
  Widget build(BuildContext context) {
    final t = LocaleController.instance.strings;
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border),
      ),
      title: Text(
        isTextColor ? t.selectTextColor : t.selectBackgroundColor,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _colors.map((color) {
          final isSelected = color.toARGB32() == currentColor.toARGB32();
          return GestureDetector(
            onTap: () => Navigator.pop(context, color),
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
                      color: color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
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
          child: Text(t.cancel),
        ),
      ],
    );
  }
}
