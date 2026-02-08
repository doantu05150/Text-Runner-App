import 'package:flutter/material.dart';

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
    return Container(
      height: shouldExpand ? null : (inputHeight > 0 ? inputHeight : fontSize * 1.2 + verticalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildTextField(),
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
          color: textColor.withValues(alpha: 0.5),
          height: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none,
        filled: false,
        isDense: true,
      ),
    );
  }
}
