import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography using Playfair Display (serif) and Inter (sans).
abstract final class AppTextStyles {
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    Color color = AppColors.primary,
    double letterSpacing = 0,
    double height = 1.2,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );
  }

  static TextStyle playfair({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    Color color = AppColors.primary,
    double height = 1.25,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: TextDecoration.none,
      decorationColor: Colors.transparent,
    );
  }
}
