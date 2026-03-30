import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final double inputHeight;
  final double verticalPadding;
  final void Function()? onChanged;
  final bool shouldExpand;

  const TextInputWidget({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.fontFamily,
    required this.textColor,
    required this.inputHeight,
    required this.verticalPadding,
    this.onChanged,
    this.shouldExpand = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: shouldExpand ? null : (inputHeight > 0 ? inputHeight : fontSize * 1.2 + verticalPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildTextField(),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: controller,
      maxLines: null,
      expands: shouldExpand,
      keyboardType: TextInputType.multiline,
      textAlignVertical: TextAlignVertical.top,
      onChanged: (_) => onChanged?.call(),
      cursorColor: AppColors.primary,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: fontFamily,
        color: textColor,
        height: 1.2,
      ),
      decoration: InputDecoration(
        hintText: 'Nhập văn bản...',
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
          color: AppColors.textMuted,
          height: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
      ),
    );
  }
}
