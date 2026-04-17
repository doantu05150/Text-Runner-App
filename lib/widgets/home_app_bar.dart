import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

const _accentGradient = LinearGradient(
  colors: [Color(0xFF00E5FF), Color(0xFFFF2D95)],
);

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          backgroundColor: AppColors.bgCard,
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(1.5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.5),
                  child: Image.asset(
                    'assets/images/logo-trans.png',
                    height: 36,
                    width: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) =>
                    _accentGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'GlowTextify',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              Text(
                ' LED',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
