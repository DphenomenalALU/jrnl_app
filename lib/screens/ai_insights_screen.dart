import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';

/// Shown when the user taps **EXPLORE DEEPLY** on the journal screen.
///
/// When [onBack] is set, the back control calls it (e.g. embedded in [JournalScreen]
/// so the main bottom nav stays visible). Otherwise [Navigator.maybePop] is used.
class AiInsightsScreen extends StatelessWidget {
  const AiInsightsScreen({super.key, this.onBack});

  /// Prefer this over routing when the screen should sit above [JrnlBottomNav].
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AiInsightsAppBar(onBack: onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AiReflectionsBanner(),
                    const SizedBox(height: 20),
                    const _InsightCard(),
                    const SizedBox(height: 32),
                    const _ActionItemsSection(),
                    const SizedBox(height: 28),
                    _SaveShareButtons(
                      onSave: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved to insights')),
                        );
                      },
                      onShare: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiInsightsAppBar extends StatelessWidget {
  const _AiInsightsAppBar({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            icon: SvgPicture.asset(
              'lib/assets/journal_icons/ai-insights-back.svg',
              width: 10.8,
              height: 18,
              fit: BoxFit.contain,
            ),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'AI INSIGHTS',
              textAlign: TextAlign.center,
              style: AppTextStyles.crimsonText(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: 2.0,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            tooltip: 'More',
          ),
        ],
      ),
    );
  }
}

class _AiReflectionsBanner extends StatelessWidget {
  const _AiReflectionsBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
        decoration: const BoxDecoration(
          color: AppColors.primary,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AI Reflections',
                    style: AppTextStyles.playfair(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daily Synthesis',
                    style: AppTextStyles.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.65),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 19,
              height: 20,
              child: SvgPicture.asset(
                'lib/assets/journal_icons/ai-reflections-magic.svg',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  static const double _innerPad = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _innerPad,
              _innerPad,
              _innerPad,
              0,
            ),
            child: SizedBox(
              height: 188,
              width: double.infinity,
              child: Image.asset(
                'lib/assets/ai-image.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _innerPad,
              _innerPad,
              _innerPad,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your entry today suggests a strong sense of purpose '
                  'coupled with minor physical fatigue.',
                  style: AppTextStyles.playfair(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.52,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "You've navigated professional challenges with high resilience, "
                  'but your mention of late-night emails indicates a need for '
                  'digital boundaries. There is a clear pattern of productivity '
                  'masking a growing need for rest.',
                  style: AppTextStyles.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.72,
                    color: AppColors.labelSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                const _ClarityRow(clarity: 0.75),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClarityRow extends StatelessWidget {
  const _ClarityRow({required this.clarity});

  final double clarity;

  @override
  Widget build(BuildContext context) {
    final p = clarity.clamp(0.0, 1.0);
    final pct = (p * 100).round();
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: p,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$pct% CLARITY',
          style: AppTextStyles.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _ActionItemsSection extends StatelessWidget {
  const _ActionItemsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Action Items',
              style: AppTextStyles.playfair(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
            const Spacer(),
            Text(
              'SUGGESTED FOR YOU',
              style: AppTextStyles.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ActionTile(
          leading: SvgPicture.asset(
            'lib/assets/journal_icons/action-item-reflect.svg',
            width: 21,
            height: 19,
            fit: BoxFit.contain,
          ),
          title: 'Reflect on office boundaries',
          subtitle: 'Consider why you felt overwhelmed at work today.',
        ),
        const Divider(height: 1, color: AppColors.divider),
        _ActionTile(
          leading: SvgPicture.asset(
            'lib/assets/journal_icons/action-item-resonance.svg',
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          title: '5-Minute Resonance',
          subtitle: 'Try a short breathing exercise to reset your nervous system.',
        ),
        const Divider(height: 1, color: AppColors.divider),
        _ActionTile(
          leading: SvgPicture.asset(
            'lib/assets/journal_icons/action-item-acknowledge.svg',
            width: 19,
            height: 20,
            fit: BoxFit.contain,
          ),
          title: "Acknowledge a 'Win'",
          subtitle: 'Journal briefly about one small success from this morning.',
        ),
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.leading,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Align(
                alignment: Alignment.topLeft,
                child: leading,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppColors.labelSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.labelTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveShareButtons extends StatelessWidget {
  const _SaveShareButtons({
    required this.onSave,
    required this.onShare,
  });

  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'SAVE TO INSIGHTS',
            style: AppTextStyles.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onShare,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1),
            backgroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'SHARE WITH THERAPIST',
            style: AppTextStyles.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
