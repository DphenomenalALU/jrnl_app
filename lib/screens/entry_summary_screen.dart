import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'consistency_screen.dart';

/// Post-entry emotional evaluation (discrete sliders + analytical note).
class EntrySummaryScreen extends StatefulWidget {
  const EntrySummaryScreen({
    super.key,
    this.onContinueToLeaderboard,
  });

  /// Invoked after [ConsistencyScreen] CONTINUE (pops back to shell + tab switch).
  final VoidCallback? onContinueToLeaderboard;

  @override
  State<EntrySummaryScreen> createState() => _EntrySummaryScreenState();
}

class _EntrySummaryScreenState extends State<EntrySummaryScreen> {
  /// 0–4 for each slider (mock defaults match design: Energy 4th, Mood center, Internal last).
  int _energyIndex = 3;
  int _moodIndex = 2;
  int _internalIndex = 4;

  static const _energyLabels = [
    'Exhausted',
    'Drained',
    'Balanced',
    'Energetic',
    'Hyper',
  ];
  static const _moodLabels = [
    'Low',
    'Flat',
    'Steady',
    'Bright',
    'Radiant',
  ];
  static const _internalLabels = [
    'Panicked',
    'Uneasy',
    'Calm',
    'Focused',
    'Zen',
  ];

  void _openConsistency() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => ConsistencyScreen(
          onContinue: () {
            Navigator.of(ctx).popUntil((route) => route.isFirst);
            widget.onContinueToLeaderboard?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionTime = DateFormat('h:mm a').format(DateTime.now());

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: SelectionContainer.disabled(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        icon: SvgPicture.asset(
                          'lib/assets/journal_icons/close.svg',
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                        tooltip: 'Close',
                      ),
                      Expanded(
                        child: Text(
                          'Entry Summary',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.playfair(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                const SizedBox(height: 20),
                Text(
                  'Emotional Evaluation',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.15,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Session recorded at $sessionTime',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.labelTertiary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: 62,
                    child: Container(height: 1, color: AppColors.divider),
                  ),
                ),
                const SizedBox(height: 44),
                _DiscreteSliderRow(
                  title: 'Energy',
                  valueLabel: _energyLabels[_energyIndex],
                  leftEnd: 'EXHAUSTED',
                  rightEnd: 'HYPER',
                  selectedIndex: _energyIndex,
                  onChanged: (i) => setState(() => _energyIndex = i),
                ),
                const SizedBox(height: 40),
                _DiscreteSliderRow(
                  title: 'Mood',
                  valueLabel: _moodLabels[_moodIndex],
                  leftEnd: 'LOW',
                  rightEnd: 'RADIANT',
                  selectedIndex: _moodIndex,
                  onChanged: (i) => setState(() => _moodIndex = i),
                ),
                const SizedBox(height: 40),
                _DiscreteSliderRow(
                  title: 'Internal State',
                  valueLabel: _internalLabels[_internalIndex],
                  leftEnd: 'PANICKED',
                  rightEnd: 'ZEN',
                  selectedIndex: _internalIndex,
                  onChanged: (i) => setState(() => _internalIndex = i),
                ),
                const SizedBox(height: 64),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: 24),
                Center(child: Icon(Icons.auto_awesome, size: 16, color: AppColors.labelSecondary)),
                const SizedBox(height: 12),
                Text(
                  'ANALYTICAL NOTE',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Your energy is elevated following today\'s entry. This sequence often correlates with your most creative periods.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.labelSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _openConsistency,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'FINISH ENTRY',
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

class _DiscreteSliderRow extends StatelessWidget {
  const _DiscreteSliderRow({
    required this.title,
    required this.valueLabel,
    required this.leftEnd,
    required this.rightEnd,
    required this.selectedIndex,
    required this.onChanged,
  });

  final String title;
  final String valueLabel;
  final String leftEnd;
  final String rightEnd;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.playfair(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  valueLabel,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.playfair(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _DotTrack(
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftEnd,
              style: AppTextStyles.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
            Text(
              rightEnd,
              style: AppTextStyles.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DotTrack extends StatelessWidget {
  const _DotTrack({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 6,
            right: 6,
            child: Container(
              height: 2,
              color: AppColors.primary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final selected = i == selectedIndex;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  width: selected ? 16 : 10,
                  height: selected ? 16 : 10,
                  alignment: Alignment.center,
                  child: Container(
                    width: selected ? 14 : 8,
                    height: selected ? 14 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary
                          : AppColors.labelTertiary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
