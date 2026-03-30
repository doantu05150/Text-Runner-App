import 'package:flutter/material.dart';
import 'app_button.dart';

class ActionBarWidget extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onSettingsPressed;
  final VoidCallback onSavePressed;

  const ActionBarWidget({
    super.key,
    required this.iconColor,
    required this.onSettingsPressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIconButton(
          icon: Icons.save_rounded,
          onPressed: onSavePressed,
          tooltip: 'Lưu văn bản',
        ),
        const SizedBox(width: 8),
        AppIconButton(
          icon: Icons.tune_rounded,
          onPressed: onSettingsPressed,
          tooltip: 'Cài đặt',
        ),
      ],
    );
  }
}
