import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/journal/domain/journal_entry.dart';
import '../src/features/journal/presentation/insights_provider.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';

/// Shown when the user taps **EXPLORE DEEPLY** on the journal screen.
///
/// [entryId] is required when displaying insights for a specific entry.
/// [onBack] is called instead of Navigator.pop when set (embedded mode).
class AiInsightsScreen extends ConsumerStatefulWidget {
  const AiInsightsScreen({super.key, this.onBack, this.entryId});

  final VoidCallback? onBack;
  final String? entryId;

  @override
  ConsumerState<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends ConsumerState<AiInsightsScreen> {
  bool _generating = false;
  bool _saving = false;

  Future<void> _generateInsights() async {
    final uid = ref.read(currentUidProvider);
    final entryId = widget.entryId;
    if (uid == null || entryId == null) return;

    setState(() => _generating = true);
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('generateInsights');
      await callable.call({'uid': uid, 'entryId': entryId});
      // Firestore stream will update automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate insights: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _saveInsight(String insight) async {
    final uid = ref.read(currentUidProvider);
    final entryId = widget.entryId;
    if (uid == null || entryId == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(journalEntriesRepositoryProvider).saveInsight(
            entryId: entryId,
            insight: insight,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insight saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = widget.entryId != null
        ? ref.watch(insightsEntryProvider(widget.entryId!))
        : const AsyncData<JournalEntry?>(null);

    final entry = entryAsync.valueOrNull;
    final isTranscribing = entry?.status == EntryStatus.transcribing;
    final hasInsight =
        entry?.aiInsight != null && entry!.aiInsight!.isNotEmpty;
    final alreadySaved = entry?.status == EntryStatus.done;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AiInsightsAppBar(onBack: widget.onBack),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _AiReflectionsBanner(),
                    const SizedBox(height: 20),
                    if (isTranscribing)
                      _TranscribingState()
                    else if (hasInsight)
                      _InsightCard(insight: entry!.aiInsight!)
                    else
                      _InsightCard(insight: null),
                    const SizedBox(height: 32),
                    if (!isTranscribing) ...[
                      const _ActionItemsSection(),
                      const SizedBox(height: 28),
                      _SaveShareButtons(
                        generating: _generating,
                        saving: _saving,
                        hasInsight: hasInsight,
                        alreadySaved: alreadySaved,
                        onGenerate: _generateInsights,
                        onSave: hasInsight
                            ? () => _saveInsight(entry!.aiInsight!)
                            : null,
                        onShare: () {},
                      ),
                    ],
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

class _TranscribingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 20),
          Text(
            'Transcribing your entry…',
            style: AppTextStyles.playfair(
              fontSize: 17,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.labelSecondary,
              height: 1.4,
            ),
          ),
        ],
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
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
        decoration: const BoxDecoration(color: AppColors.primary),
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
  const _InsightCard({this.insight});

  final String? insight;

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
                _innerPad, _innerPad, _innerPad, 0),
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
                _innerPad, _innerPad, _innerPad, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  insight ??
                      'Tap "Generate Insights" below to analyse this entry.',
                  style: AppTextStyles.playfair(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.52,
                    color: insight != null
                        ? AppColors.primary
                        : AppColors.labelTertiary,
                  ),
                ),
                if (insight != null) ...[
                  const SizedBox(height: 20),
                  const _ClarityRow(clarity: 0.75),
                ],
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
          subtitle:
              'Try a short breathing exercise to reset your nervous system.',
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
          subtitle:
              'Journal briefly about one small success from this morning.',
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
    required this.generating,
    required this.saving,
    required this.hasInsight,
    required this.alreadySaved,
    required this.onGenerate,
    required this.onSave,
    required this.onShare,
  });

  final bool generating;
  final bool saving;
  final bool hasInsight;
  final bool alreadySaved;
  final VoidCallback onGenerate;
  final VoidCallback? onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasInsight)
          FilledButton(
            onPressed: generating ? null : onGenerate,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'GENERATE INSIGHTS',
                    style: AppTextStyles.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
          )
        else
          FilledButton(
            onPressed: (saving || alreadySaved) ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    alreadySaved ? 'SAVED ✓' : 'SAVE TO INSIGHTS',
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
