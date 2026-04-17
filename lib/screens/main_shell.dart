import 'package:flutter/material.dart';
import '../ads/ad_ids.dart';
import '../ads/global_inter_ad.dart';
import '../services/locale_controller.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

const _accentGradient = LinearGradient(
  colors: [Color(0xFF00E5FF), Color(0xFFFF2D95)],
);

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const String _interAdUnitId = AdIds.homeToSavedInter;

  static const _placements = {
    (from: 0, to: 1): 'home_to_saved',
    (from: 2, to: 0): 'settings_to_home',
    (from: 2, to: 1): 'settings_to_saved',
  };

  @override
  void initState() {
    super.initState();
    _preloadInterAd();
  }

  void _preloadInterAd({String placement = 'tab_inter'}) {
    GlobalInterAd.loadAd(
      adUnitId: _interAdUnitId,
      adPlacement: placement,
    );
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    final from = _currentIndex;
    final placement = _placements[(from: from, to: index)];
    final shouldShowAd = placement != null;

    if (shouldShowAd) {
      void navigate(String? _) {
        if (!mounted) return;
        setState(() => _currentIndex = index);
        _preloadInterAd(placement: placement);
      }

      if (GlobalInterAd.isReady) {
        GlobalInterAd.showAd(onDismissed: navigate);
      } else {
        navigate(null);
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleController.instance.code,
      builder: (context, _, __) {
        final t = LocaleController.instance.strings;
        return Scaffold(
          backgroundColor: AppColors.bgMain,
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              HomeScreen(),
              SavedScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: _AppBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            labels: [t.home, t.saved, t.settings],
          ),
        );
      },
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.labels,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    (icon: Icons.bookmark_border_rounded, activeIcon: Icons.bookmark_rounded),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient accent line at top
          Container(
            height: 1,
            decoration: const BoxDecoration(gradient: _accentGradient),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 8,
              bottom: bottomPadding > 0 ? bottomPadding : 12,
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                final isActive = i == currentIndex;
                return _NavItem(
                  icon: _items[i].icon,
                  activeIcon: _items[i].activeIcon,
                  label: labels[i],
                  isActive: isActive,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontSize: 11,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
