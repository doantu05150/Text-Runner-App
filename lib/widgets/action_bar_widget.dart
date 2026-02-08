import 'package:flutter/material.dart';

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
        IconButton(
          icon: Icon(Icons.save, color: iconColor),
          onPressed: onSavePressed,
          tooltip: 'Lưu văn bản',
        ),
        IconButton(
          icon: Icon(Icons.settings, color: iconColor),
          onPressed: onSettingsPressed,
          tooltip: 'Cài đặt',
        ),
      ],
    );
  }
}
