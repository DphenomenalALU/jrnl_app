import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/home/presentation/home_insights_provider.dart';
import '../src/features/home/domain/home_insights.dart';
import '../src/features/prompts/presentation/latest_prompt_provider.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';

/// Home tab content matching the JRNL home design (scrollable body only;
/// shell provides bottom navigation).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onStartJournaling});

  /// Switches to the Journal tab; handled by [MainShell].
  final VoidCallback? onStartJournaling;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(currentAppUserProvider).valueOrNull;
    final userFirstName =
        _firstNameFromDisplayName(appUser?.displayName) ?? 'Friend';
    final dateLine = DateFormat(
      'MMM d, y',
    ).format(DateTime.now()).toUpperCase();
    final promptText =
        ref.watch(latestPromptProvider).valueOrNull?.text ??
        'What is one small thing that brought you clarity today?';
    final insights = ref.watch(homeInsightsProvider).valueOrNull;
    final useMock = ref.watch(useMockDataProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(dateLine: dateLine),
                const SizedBox(height: 28),
                _GreetingSection(firstName: userFirstName),
                const SizedBox(height: 24),
                _HairlineDivider(),
                const SizedBox(height: 28),
                Text(
                  "TODAY'S REFLECTION",
                  style: AppTextStyles.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                    color: AppColors.labelTertiary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '“$promptText”',
                  style: AppTextStyles.playfair(
                    fontSize: 19,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                _StartJournalingButton(onTap: onStartJournaling),
                const SizedBox(height: 36),
                _StatsHeader(),
                const SizedBox(height: 20),
                _StatsGrid(activeDays: appUser?.streakCount ?? 0),
                const SizedBox(height: 28),
                _HairlineDivider(),
                const SizedBox(height: 28),
                Text(
                  'OBSERVATIONS',
                  style: AppTextStyles.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'PATTERN IDENTIFIED',
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.labelSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  insights?.observationBody ??
                      'Write a few entries to unlock personalized observations.',
                  style: AppTextStyles.playfair(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _HairlineDivider(),
                const SizedBox(height: 24),
                Text(
                  'EMOTIONAL BASELINE',
                  style: AppTextStyles.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.4,
                    color: AppColors.labelTertiary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _EmotionalBaselineCard(
                  baseline: insights?.baseline,
                  showMockCopy: useMock,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionalBaselineCard extends StatelessWidget {
  const _EmotionalBaselineCard({
    required this.baseline,
    required this.showMockCopy,
  });

  final EmotionalBaseline? baseline;
  final bool showMockCopy;

  @override
  Widget build(BuildContext context) {
    if (baseline == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.inputSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          showMockCopy
              ? 'Mock mode is enabled. Switch it off to see real baseline once you have at least 3 evaluated entries.'
              : 'Write and evaluate at least 3 entries to unlock your baseline.',
          style: AppTextStyles.playfair(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: AppColors.labelSecondary,
            height: 1.45,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.inputSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _BaselineMetric(
                  label: 'ENERGY',
                  value: baseline!.energyLabel,
                ),
              ),
              Expanded(
                child: _BaselineMetric(
                  label: 'MOOD',
                  value: baseline!.moodLabel,
                ),
              ),
              Expanded(
                child: _BaselineMetric(
                  label: 'STATE',
                  value: baseline!.internalLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            baseline!.summary,
            style: AppTextStyles.playfair(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: AppColors.primary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Based on ${baseline!.sampleSize} recent check-ins',
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.labelTertiary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaselineMetric extends StatelessWidget {
  const _BaselineMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.labelTertiary,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.playfair(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

String? _firstNameFromDisplayName(String? displayName) {
  final raw = displayName?.trim();
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.split(' ').where((p) => p.trim().isNotEmpty).toList();
  return parts.isEmpty ? raw : parts.first;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.dateLine});

  final String dateLine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dateLine,
                style: AppTextStyles.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: AppColors.labelTertiary,
                  height: 1,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: SvgPicture.asset(
                'lib/assets/jrnl-logo.svg',
                height: 14,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(
                  Icons.menu,
                  size: 22,
                  color: AppColors.primary,
                ),
                tooltip: 'Menu',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final salutation = hour < 12
        ? 'Good Morning,'
        : hour < 17
        ? 'Good Afternoon,'
        : 'Good Evening,';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salutation,
          style: AppTextStyles.playfair(
            fontSize: 43,
            fontWeight: FontWeight.w400,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$firstName.',
          style: AppTextStyles.playfair(
            fontSize: 43,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.divider);
  }
}

class _StartJournalingButton extends StatelessWidget {
  const _StartJournalingButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'START JOURNALING',
                  style: AppTextStyles.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.6,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              Text(
                '→',
                style: AppTextStyles.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, size: 16, color: AppColors.labelSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "TODAY'S REFLECTION",
            style: AppTextStyles.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: AppColors.primary,
              height: 1,
            ),
          ),
        ),
        Text(
          'DETAILS',
          style: AppTextStyles.playfair(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
            color: AppColors.labelTertiary,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.activeDays});

  final int activeDays;

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
                'ACTIVE DAYS',
                style: AppTextStyles.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.labelSecondary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$activeDays',
                    style: AppTextStyles.playfair(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '—',
                    style: AppTextStyles.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.labelTertiary,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GLOBAL RANK',
                textAlign: TextAlign.right,
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
                '#12',
                textAlign: TextAlign.right,
                style: AppTextStyles.playfair(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
