import 'package:flutter/material.dart';

import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: AppTextStyles.playfair(
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: AppTextStyles.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

