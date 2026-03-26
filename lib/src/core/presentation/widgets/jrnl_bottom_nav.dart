import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class JrnlBottomNav extends StatelessWidget {
  const JrnlBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(asset: 'lib/assets/navbar_icons/home-icon.svg', semanticLabel: 'Home'),
    _NavItem(asset: 'lib/assets/navbar_icons/journal-icon.svg', semanticLabel: 'Journal'),
    _NavItem(asset: 'lib/assets/navbar_icons/leaderboard-icon.svg', semanticLabel: 'Leaderboard'),
    _NavItem(asset: 'lib/assets/navbar_icons/profile-icon.svg', semanticLabel: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: AppColors.divider),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_items.length, (i) {
                  final selected = i == currentIndex;
                  return _NavButton(
                    item: _items[i],
                    selected: selected,
                    onTap: () => onTap(i),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.asset, required this.semanticLabel});

  final String asset;
  final String semanticLabel;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.labelTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Center(
          child: Semantics(
            button: true,
            selected: selected,
            label: item.semanticLabel,
            child: SvgPicture.asset(
              item.asset,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
