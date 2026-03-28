import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/profile/presentation/profile_stats_provider.dart';
import 'settings_screen.dart';
import 'user_profile_screen.dart';

/// Profile tab: achievements, standing, XP, routine milestones, and inner void badges.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const double _horizontalPad = 24;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);
    final stats = statsAsync.valueOrNull;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                child: _AchievementsAppBar(
                  onSettings: () => Navigator.of(context,
                          rootNavigator: true)
                      .push<void>(MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen())),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _HairlineDivider(),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _StandingXpRow(
                  tierLabel: stats?.tierLabel ?? '—',
                  xpTotal: stats?.xpTotal ?? 0,
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _XpProgressBar(progress: stats?.progressToNextTier ?? 0),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    stats == null
                        ? '—'
                        : '${stats.xpRemainingToNextTier} XP remaining until ${stats.nextTierLabel}',
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
              const SizedBox(height: 52),
              const _SectionTitle(label: 'THE ROUTINE'),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _RoutineRow(),
              ),
              const SizedBox(height: 56),
              const _SectionTitle(label: 'INNER VOID'),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: _horizontalPad),
                child: _InnerVoidSection(),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsAppBar extends StatelessWidget {
  const _AchievementsAppBar({this.onSettings});

  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onSettings,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(
            Icons.settings_outlined,
            size: 24,
            color: AppColors.primary,
          ),
          tooltip: 'Settings',
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
        _ProfileAvatar(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const UserProfileScreen(mode: UserProfileMode.me),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = ClipOval(
      child: Image.asset(
        'lib/assets/ai-image.png',
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 44,
          height: 44,
          color: AppColors.inputSurface,
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: AppColors.labelTertiary, size: 24),
        ),
      ),
    );
    if (onTap == null) return child;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
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
  const _StandingXpRow({
    required this.tierLabel,
    required this.xpTotal,
  });

  final String tierLabel;
  final int xpTotal;

  @override
  Widget build(BuildContext context) {
    final xpLine = NumberFormat.decimalPattern().format(xpTotal);
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
                tierLabel,
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
                xpLine,
                style: AppTextStyles.inter(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
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
      height: 56,
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
            svgAsset: 'lib/assets/journal_icons/routine_continuous.svg',
            title: '7 DAY',
            subtitle: 'Continuous',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoutineCard(
            filled: true,
            svgAsset: 'lib/assets/journal_icons/routine_calendar.svg',
            title: '30 DAY',
            subtitle: 'Dedication',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RoutineCard(
            filled: false,
            svgAsset: 'lib/assets/journal_icons/routine_lock.svg',
            title: 'YEARLY',
            subtitle: 'Persistence',
          ),
        ),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.filled,
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });

  final bool filled;
  final String svgAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final titleColor = filled ? AppColors.primary : AppColors.labelTertiary;
    final subtitleColor = filled
        ? AppColors.labelSecondary
        : AppColors.labelTertiary.withValues(alpha: 0.75);
    final squareBg = filled ? AppColors.primary : const Color(0xFFF0F0F2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: squareBg),
              if (!filled)
                CustomPaint(
                  painter: _RoutineLockedDashedBorderPainter(
                    color: AppColors.labelTertiary.withValues(alpha: 0.45),
                  ),
                ),
              Center(
                child: SvgPicture.asset(
                  svgAsset,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: titleColor,
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
            color: subtitleColor,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

/// Dashed stroke on the perimeter of the locked routine square.
class _RoutineLockedDashedBorderPainter extends CustomPainter {
  _RoutineLockedDashedBorderPainter({required this.color});

  final Color color;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    void dashedSegment(Offset a, Offset b) {
      final delta = b - a;
      final len = delta.distance;
      if (len == 0) return;
      final dir = delta / len;
      var t = 0.0;
      while (t < len) {
        final end = (t + _dash).clamp(0.0, len);
        canvas.drawLine(a + dir * t, a + dir * end, paint);
        t += _dash + _gap;
      }
    }

    const inset = 0.5;
    final w = size.width;
    final h = size.height;
    final topLeft = Offset(inset, inset);
    final topRight = Offset(w - inset, inset);
    final bottomRight = Offset(w - inset, h - inset);
    final bottomLeft = Offset(inset, h - inset);

    dashedSegment(topLeft, topRight);
    dashedSegment(topRight, bottomRight);
    dashedSegment(bottomRight, bottomLeft);
    dashedSegment(bottomLeft, topLeft);
  }

  @override
  bool shouldRepaint(covariant _RoutineLockedDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _InnerVoidSection extends StatelessWidget {
  const _InnerVoidSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InnerVoidCategory(
                svgAsset: 'lib/assets/journal_icons/inner_void_deep.svg',
                title: 'DEEP',
                subtitle: 'Reflection',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InnerVoidCategory(
                svgAsset: 'lib/assets/journal_icons/inner_void_explorer.svg',
                title: 'EXPLORER',
                subtitle: 'Emotional',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InnerVoidCategory(
                svgAsset: 'lib/assets/journal_icons/inner_void_oracle.svg',
                title: 'ORACLE',
                subtitle: 'AI Insights',
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const _SevenDayVelocityCard(),
      ],
    );
  }
}

class _InnerVoidCategory extends StatelessWidget {
  const _InnerVoidCategory({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
  });

  final String svgAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            svgAsset,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTextStyles.playfair(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: AppColors.primary,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _SevenDayVelocityCard extends StatelessWidget {
  const _SevenDayVelocityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'lib/assets/journal_icons/seven_day_velocity_icon.svg',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'STATUS',
                    style: AppTextStyles.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                      color: AppColors.labelSecondary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Authenticated',
                    style: AppTextStyles.playfair(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Seven-Day Velocity',
            style: AppTextStyles.playfair(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 2, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '“Consistent adherence to the practice for a full septenary cycle. '
                    'This mark signifies the emergence of structural mental discipline.”',
                    style: AppTextStyles.playfair(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATE EARNED',
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                        color: AppColors.labelSecondary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'OCT 24, 2025',
                      style: AppTextStyles.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.zero,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.zero,
                  splashColor: Colors.white.withValues(alpha: 0.12),
                  highlightColor: Colors.white.withValues(alpha: 0.06),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Text(
                      '+100 XP',
                      style: AppTextStyles.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
