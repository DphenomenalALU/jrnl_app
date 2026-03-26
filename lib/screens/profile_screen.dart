import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Profile tab: achievements, standing, XP, routine milestones, and inner void badges.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const double _horizontalPad = 24;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 4, 16, 0),
                child: _AchievementsAppBar(),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _HairlineDivider(),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _StandingXpRow(),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _XpProgressBar(progress: 0.78),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '*530 XP remaining until Tier XIII*',
                    style: AppTextStyles.playfair(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              const _SectionTitle(label: 'THE ROUTINE'),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _RoutineRow(),
              ),
              const SizedBox(height: 40),
              const _SectionTitle(label: 'INNER VOID'),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _InnerVoidRow(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsAppBar extends StatelessWidget {
  const _AchievementsAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.primary,
          ),
          tooltip: 'Back',
        ),
        Expanded(
          child: Text(
            'Achievements',
            textAlign: TextAlign.center,
            style: AppTextStyles.playfair(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.15,
              color: AppColors.primary,
            ),
          ),
        ),
        const _ProfileAvatar(),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        'lib/assets/ai-image.png',
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 44,
          height: 44,
          color: AppColors.inputSurface,
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: AppColors.labelTertiary, size: 24),
        ),
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.divider);
  }
}

class _StandingXpRow extends StatelessWidget {
  const _StandingXpRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT STANDING',
                style: AppTextStyles.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.labelSecondary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tier XII',
                style: AppTextStyles.playfair(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'XP TOTAL',
                style: AppTextStyles.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.labelSecondary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '2,450',
                style: AppTextStyles.playfair(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  height: 1,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _XpProgressBar extends StatelessWidget {
  const _XpProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final filledFlex = (progress * 100).round().clamp(1, 99);
    final emptyFlex = 100 - filledFlex;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            flex: filledFlex,
            child: ColoredBox(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PROGRESS $pct%',
                    style: AppTextStyles.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: emptyFlex.clamp(1, 100),
            child: const ColoredBox(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _RoutineCard(
            filled: true,
            icon: Icons.sync,
            title: '7 DAY',
            subtitle: '*Continuous*',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoutineCard(
            filled: true,
            icon: Icons.calendar_today_outlined,
            title: '30 DAY',
            subtitle: '*Dedication*',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoutineCard(
            filled: false,
            icon: Icons.lock_outline,
            title: 'YEARLY',
            subtitle: '*Persistence*',
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.filled,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool filled;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final primary = filled ? AppColors.primary : AppColors.labelTertiary;
    final onBg = filled ? Colors.white : AppColors.labelTertiary;
    final bg = filled ? AppColors.primary : const Color(0xFFF0F0F2);

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: filled ? AppColors.primary : AppColors.labelTertiary.withValues(alpha: 0.45),
            width: filled ? 1 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(icon, size: 28, color: onBg),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.playfair(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  color: primary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InnerVoidRow extends StatelessWidget {
  const _InnerVoidRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _VoidOrb(icon: Icons.psychology_outlined),
        _VoidOrb(icon: Icons.explore_outlined),
        _VoidOrb(icon: Icons.auto_awesome),
      ],
    );
  }
}

class _VoidOrb extends StatelessWidget {
  const _VoidOrb({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 36, color: Colors.white),
    );
  }
}
