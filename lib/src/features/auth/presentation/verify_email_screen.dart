import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';
import 'auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _loading = false;

  Future<void> _resend() async {
    setState(() => _loading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return;
      await user.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.message ?? 'Could not resend email. Try again.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checked() async {
    setState(() => _loading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return;

      await user.reload();
      final refreshed = auth.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        if (mounted) context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Still not verified. Check your email, then try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not refresh verification status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signOut() async {
    final auth = ref.read(firebaseAuthProvider);
    await auth.signOut();
    if (mounted) context.go('/auth/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(firebaseAuthProvider).currentUser?.email ?? '';

    return AuthScaffold(
      title: 'Verify your email.',
      subtitle: 'We sent a verification link to:\n$email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: _loading ? null : _checked,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _loading ? 'CHECKING…' : "I'VE VERIFIED",
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
          OutlinedButton(
            onPressed: _loading ? null : _resend,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              side: const BorderSide(color: AppColors.primary, width: 1),
            ),
            child: Text(
              'RESEND EMAIL',
              style: AppTextStyles.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: AppColors.primary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loading ? null : _signOut,
            child: Text(
              'Sign out',
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
    );
  }
}

