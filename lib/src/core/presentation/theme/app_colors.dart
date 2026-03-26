import 'package:flutter/material.dart';

/// JRNL brand palette.
abstract final class AppColors {
  static const Color background = Color(0xFFF9F8F6);
  static const Color primary = Color(0xFF020617);
  static const Color labelSecondary = Color(0xFF535356);
  static const Color labelTertiary = Color(0xFF9B9BA0);
  static const Color divider = Color(0xFFE4E4E6);

  /// Journal text field / recording card background.
  static const Color inputSurface = Color(0xFFF3F3F3);

  /// Toolbar separator below image/mic (50% opacity on #8E8E93).
  static const Color journalToolbarLine = Color(0x808E8E93);

  /// Voice recording accent (waveform, mic, dot).
  static const Color recordingRed = Color(0xFFE11D48);
  static const Color recordingTint = Color(0xFFFFE4E6);
}
