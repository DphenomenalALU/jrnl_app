import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';
import 'auth_field.dart';
import 'auth_scaffold.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      await auth.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );
      }
      // Router redirect will take over to verify-email.
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-email' => 'Enter a valid email address.',
        'email-already-in-use' => 'That email is already in use.',
        'weak-password' => 'Choose a stronger password.',
        _ => e.message ?? 'Sign up failed. Try again.',
      };
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account.',
      subtitle: 'Start building consistency with daily reflection.',
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
            const SizedBox(height: 14),
            AuthField(
              controller: _password,
              label: 'Password',
              obscureText: _obscure,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return 'Password is required.';
                if (value.length < 6) return 'Use at least 6 characters.';
                return null;
              },
              trailing: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.labelTertiary,
                ),
                tooltip: _obscure ? 'Show password' : 'Hide password',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                _loading ? 'CREATING…' : 'SIGN UP',
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
                'Already have an account?',
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
