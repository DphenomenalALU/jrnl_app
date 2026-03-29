import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import 'settings_screen.dart';

void showAppMenuSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) =>
        _AppMenuSheet(pageContext: context, sheetContext: sheetContext),
  );
}

class _AppMenuSheet extends ConsumerWidget {
  const _AppMenuSheet({required this.pageContext, required this.sheetContext});

  final BuildContext pageContext;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> signOut() async {
      Navigator.of(sheetContext).pop();
      await ref.read(firebaseAuthProvider).signOut();
      if (pageContext.mounted) {
        GoRouter.maybeOf(pageContext)?.go('/auth/sign-in');
      }
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Text(
                'MENU',
                style: AppTextStyles.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: AppColors.labelTertiary,
                  height: 1,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Settings',
                style: AppTextStyles.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              subtitle: Text(
                'Appearance, voice, notifications',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.35,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(pageContext, rootNavigator: true).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.emoji_events_outlined,
                color: AppColors.primary,
              ),
              title: Text(
                'Achievements',
                style: AppTextStyles.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              subtitle: Text(
                'Streaks, XP, and milestones',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.35,
                ),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                GoRouter.maybeOf(pageContext)?.go('/profile');
              },
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.divider,
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.recordingRed),
              title: Text(
                'Log out',
                style: AppTextStyles.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.recordingRed,
                  height: 1.2,
                ),
              ),
              subtitle: Text(
                'Sign out of your account',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.35,
                ),
              ),
              onTap: signOut,
            ),
          ],
        ),
      ),
    );
  }
}
