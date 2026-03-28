import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';
import 'auth_field.dart';
import 'auth_scaffold.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _email;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.sendPasswordResetEmail(email: _email.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
        context.go('/auth/sign-in');
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'user-not-found' => 'No account found for that email.',
        _ => e.message ?? 'Could not send reset email. Try again.',
      };
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Reset password.',
      subtitle: 'We’ll email you a secure link to reset your password.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Email is required.';
                if (!value.contains('@')) return 'Enter a valid email.';
                return null;
              },
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _loading ? 'SENDING…' : 'SEND RESET LINK',
                style: AppTextStyles.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loading ? null : () => context.go('/auth/sign-in'),
              child: Text(
                'Back to sign in',
                style: AppTextStyles.playfair(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
