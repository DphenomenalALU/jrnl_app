import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/profile/presentation/profile_stats_provider.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';

/// Streak / tier celebration after finishing entry summary.
class ConsistencyScreen extends ConsumerWidget {
  const ConsistencyScreen({super.key, required this.onContinue});

  /// Pops the entire post-entry stack, then shell switches tab (see caller).
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(useMockDataProvider);
    if (demo) {
      return _ConsistencyDemoView(onContinue: onContinue);
    }
    return _ConsistencyRealView(onContinue: onContinue);
  }
}

class _ConsistencyRealView extends ConsumerWidget {
  const _ConsistencyRealView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    final stats = ref.watch(profileStatsProvider).valueOrNull;
    final streak = user?.streakCount ?? 0;
    final xpLine = NumberFormat.decimalPattern().format(stats?.xpTotal ?? 0);
    final tier = stats?.tierLabel ?? user?.tier ?? 'Tier I';
    final nextTier = stats?.nextTierLabel ?? 'Tier II';
    final progress = stats?.progressToNextTier ?? 0.0;

    final subtitle = streak > 0
        ? 'Keep showing up—small sessions compound.'
        : 'Every entry counts toward your rhythm.';

    final bodyCopy =
        'Thanks for closing the loop on this session. Your check-ins build the signal we use for insights and milestones.';

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SelectionContainer.disabled(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: SvgPicture.asset(
                        'lib/assets/journal_icons/close.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$streak',
                        style: AppTextStyles.playfair(
                          fontSize: 66,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          height: 1.05,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        streak == 1 ? ' Day' : ' Days',
                        style: AppTextStyles.playfair(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          height: 1.1,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.labelTertiary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 44),
                  Row(
                    children: [
                      Text(
                        '$xpLine XP',
                        style: AppTextStyles.playfair(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        nextTier.toUpperCase(),
                        style: AppTextStyles.playfair(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.4,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current standing: $tier',
                    style: AppTextStyles.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.labelSecondary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TierProgressLine(percentTowardNextTier: progress),
                  const SizedBox(height: 40),
                  Center(child: _TierBadgeRing(tierLabel: tier)),
                  const SizedBox(height: 36),
                  Text(
                    'Consistency builds clarity.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    bodyCopy,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.labelSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: AppTextStyles.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConsistencyDemoView extends StatelessWidget {
  const _ConsistencyDemoView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: SelectionContainer.disabled(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      icon: SvgPicture.asset(
                        'lib/assets/journal_icons/close.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      tooltip: 'Close',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '125',
                        style: AppTextStyles.playfair(
                          fontSize: 66,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          height: 1.05,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' Days',
                        style: AppTextStyles.playfair(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          height: 1.1,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Days of continuous growth.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.labelTertiary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 44),
                  Row(
                    children: [
                      Text(
                        '+50 XP GAINED',
                        style: AppTextStyles.playfair(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'TIER XIII',
                        style: AppTextStyles.playfair(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.normal,
                          letterSpacing: 0.4,
                          color: AppColors.primary.withValues(alpha: 0.5),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _TierProgressLine(percentTowardNextTier: 0.8),
                  const SizedBox(height: 40),
                  const Center(child: _MindfulnessBadge()),
                  const SizedBox(height: 36),
                  Text(
                    'Consistency builds clarity.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your energy is elevated following today\'s entry. This sequence often correlates with your most creative periods.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.playfair(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: AppColors.labelSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'CONTINUE',
                      style: AppTextStyles.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Double-stroke ring (two 1px circles) with fill only in the gap; sparkle above two-line title.
class _MindfulnessBadge extends StatelessWidget {
  const _MindfulnessBadge();

  static const double _size = 200;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_size, _size),
            painter: const _MindfulnessRingPainter(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'lib/assets/journal_icons/sparkle-large.svg',
                  width: 23,
                  height: 23,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  'MINDFULNESS',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    height: 1.15,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'MASTER',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    height: 1.15,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBadgeRing extends StatelessWidget {
  const _TierBadgeRing({required this.tierLabel});

  final String tierLabel;

  static const double _size = 200;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_size, _size),
            painter: const _MindfulnessRingPainter(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'lib/assets/journal_icons/sparkle-large.svg',
                  width: 23,
                  height: 23,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Text(
                  tierLabel,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.playfair(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    height: 1.2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MindfulnessRingPainter extends CustomPainter {
  const _MindfulnessRingPainter();

  static const Color _ring = Color(0xFFD9D9D9);

  static const double _hairline = 1;

  /// Midline spacing between outer and inner strokes (channel between double strokes).
  static const double _ringSpacing = 14;

  /// Start at top (12 o'clock); positive sweep = clockwise on the clock face in Flutter.
  static const double _startAngle = -math.pi / 2;
  static const double _progressSweep = 0.9 * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide / 2 - 4;
    final rOuterMid = maxR;
    final rInnerMid = rOuterMid - _ringSpacing;

    final strokePaint = Paint()
      ..color = _ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = _hairline
      ..isAntiAlias = true;

    canvas.drawCircle(center, rOuterMid, strokePaint);
    canvas.drawCircle(center, rInnerMid, strokePaint);

    // Fill only the gap between the two strokes (inside outer stroke, outside inner stroke).
    final outerFill = rOuterMid - _hairline / 2;
    final innerFill = rInnerMid + _hairline / 2;
    _drawAnnularSector(
      canvas,
      center,
      innerFill,
      outerFill,
      _startAngle,
      _progressSweep,
      _ring,
    );
  }

  /// Filled donut arc between [rInner] and [rOuter] (full radii, not stroke midlines).
  static void _drawAnnularSector(
    Canvas canvas,
    Offset center,
    double rInner,
    double rOuter,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final outerRect = Rect.fromCircle(center: center, radius: rOuter);
    final innerRect = Rect.fromCircle(center: center, radius: rInner);
    final path = Path()
      ..moveTo(
        center.dx + rOuter * math.cos(startAngle),
        center.dy + rOuter * math.sin(startAngle),
      )
      ..arcTo(outerRect, startAngle, sweepAngle, false)
      ..lineTo(
        center.dx + rInner * math.cos(startAngle + sweepAngle),
        center.dy + rInner * math.sin(startAngle + sweepAngle),
      )
      ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Progress toward the next tier (e.g. ~80% of the way to **TIER XIII**).
class _TierProgressLine extends StatelessWidget {
  const _TierProgressLine({required this.percentTowardNextTier});

  final double percentTowardNextTier;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final p = percentTowardNextTier.clamp(0.0, 1.0);
        return SizedBox(
          height: 1.5,
          width: w,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(height: 1.5, width: w, color: AppColors.divider),
              Container(height: 1.5, width: w * p, color: AppColors.primary),
            ],
          ),
        );
      },
    );
  }
}
