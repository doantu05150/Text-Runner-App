import 'package:flutter/material.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// Top app bar for the home screen.
///
/// Pure presentation: callbacks let the parent route, show ads, etc.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.onSavedPressed,
    required this.onSettingsPressed,
  });

  final VoidCallback onSavedPressed;
  final VoidCallback onSettingsPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = LocaleController.instance.strings;
    return AppBar(
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
            child: Icon(Icons.text_fields_rounded,
                color: AppColors.primary, size: 20),
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
          onPressed: onSavedPressed,
          tooltip: t.saved,
        ),
        const SizedBox(width: 8),
        AppIconButton(
          icon: Icons.settings_rounded,
          onPressed: onSettingsPressed,
          tooltip: t.settings,
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
