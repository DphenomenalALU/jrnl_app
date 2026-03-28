class EmotionalBaseline {
  const EmotionalBaseline({
    required this.sampleSize,
    required this.energyLabel,
    required this.moodLabel,
    required this.internalLabel,
    required this.summary,
  });

  final int sampleSize;
  final String energyLabel;
  final String moodLabel;
  final String internalLabel;
  final String summary;
}

class HomeInsights {
  const HomeInsights({
    required this.observationTitle,
    required this.observationBody,
    required this.baseline,
  });

  /// Short heading (e.g. "PATTERN IDENTIFIED").
  final String observationTitle;

  /// Main observation copy shown on Home.
  final String observationBody;

  /// Null means: not enough data yet (show empty state).
  final EmotionalBaseline? baseline;
}

