import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/core/services/app_prefs.dart';

/// App preferences / settings screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final voiceAuto = ref.watch(voiceAutoTranscribeProvider);
    final dailyReminder = ref.watch(dailyReminderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SectionHeader(label: 'APPEARANCE'),
                    _ThemeTile(current: themeMode),
                    _Divider(),
                    _SectionHeader(label: 'VOICE JOURNALING'),
                    _SwitchTile(
                      title: 'Auto-transcribe',
                      subtitle:
                          'Automatically transcribe voice entries after upload.',
                      value: voiceAuto,
                      onChanged: (v) => ref
                          .read(voiceAutoTranscribeProvider.notifier)
                          .set(v),
                    ),
                    _Divider(),
                    _SectionHeader(label: 'NOTIFICATIONS'),
                    _SwitchTile(
                      title: 'Daily reminder',
                      subtitle:
                          'Receive a daily nudge to write in your journal.',
                      value: dailyReminder,
                      onChanged: (v) =>
                          ref.read(dailyReminderProvider.notifier).set(v),
                    ),
                    const SizedBox(height: 40),
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

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.chevron_left,
                size: 28, color: AppColors.primary),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: AppTextStyles.playfair(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 44), // balance back button
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.labelTertiary,
          height: 1,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.divider,
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile({required this.current});

  final ThemeMode current;

  static const _options = [
    (ThemeMode.system, 'System'),
    (ThemeMode.light, 'Light'),
    (ThemeMode.dark, 'Dark'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: AppTextStyles.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _options.map((opt) {
              final (mode, label) = opt;
              final selected = current == mode;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(themeModeProvider.notifier).set(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.inputSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: AppTextStyles.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: selected
                            ? Colors.white
                            : AppColors.labelSecondary,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.labelSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
