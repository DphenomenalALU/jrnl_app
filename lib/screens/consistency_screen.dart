import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Streak / tier celebration after finishing entry summary.
class ConsistencyScreen extends StatelessWidget {
  const ConsistencyScreen({
    super.key,
    required this.onContinue,
  });

  /// Pops the entire post-entry stack, then shell switches tab (see caller).
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: const Icon(Icons.close, size: 22, color: AppColors.primary),
                    tooltip: 'Close',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '125 Days',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.1,
                    color: AppColors.primary,
                  ),
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
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      '150 XP GAINED',
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'TIER XII',
                      style: AppTextStyles.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.divider),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.labelTertiary.withValues(alpha: 0.35),
                              width: 2,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
                            const SizedBox(height: 12),
                            Text(
                              'MINDFULNESS MASTER',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.playfair(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                height: 1.2,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  'Consistency builds clarity.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.playfair(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }
}
