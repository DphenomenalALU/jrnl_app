import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/core/di/providers.dart';
import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';
import '../src/features/users/presentation/onboarding_complete_provider.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentAppUserProvider).valueOrNull;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
    _locationCtrl = TextEditingController(text: user?.location ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeWithoutSaving() async {
    await ref.read(setOnboardingCompleteProvider)();
  }

  Future<void> _saveAndComplete() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(usersRepositoryProvider)
          .updateProfile(
            uid: uid,
            displayName: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            location: _locationCtrl.text.trim().isEmpty
                ? null
                : _locationCtrl.text.trim(),
          );
      await ref.read(setOnboardingCompleteProvider)();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Before you begin.',
                  style: AppTextStyles.playfair(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A few details help personalize your experience — and power the social leaderboard.',
                  style: AppTextStyles.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.labelSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                _Field(
                  controller: _nameCtrl,
                  label: 'What should we call you?',
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Name is required.';
                    if (value.length > 40) {
                      return 'Keep it under 40 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _Field(controller: _locationCtrl, label: 'Location (optional)'),
                const SizedBox(height: 14),
                _Field(
                  controller: _bioCtrl,
                  label: 'About you (optional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 26),
                FilledButton(
                  onPressed: _saving ? null : _saveAndComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _saving ? null : _completeWithoutSaving,
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.playfair(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: AppColors.labelSecondary,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        height: 1.4,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.labelSecondary,
          height: 1,
        ),
        filled: true,
        fillColor: AppColors.inputSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
