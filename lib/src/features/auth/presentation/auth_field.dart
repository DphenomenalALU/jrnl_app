import 'package:flutter/material.dart';

import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
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
          fontWeight: FontWeight.w500,
          color: AppColors.labelSecondary,
        ),
        filled: true,
        fillColor: AppColors.inputSurface,
        suffixIcon: trailing,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      ),
    );
  }
}

