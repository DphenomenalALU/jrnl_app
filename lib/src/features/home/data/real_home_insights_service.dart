import 'dart:math' as math;

import '../../journal/domain/journal_entry.dart';
import '../../journal/domain/journal_entries_repository.dart';
import '../domain/home_insights.dart';
import '../domain/home_insights_service.dart';

class RealHomeInsightsService implements HomeInsightsService {
  RealHomeInsightsService(this._entriesRepository);

  final JournalEntriesRepository _entriesRepository;

  static const _energyLabels = [
    'Exhausted',
    'Drained',
    'Balanced',
    'Energetic',
    'Hyper',
  ];
  static const _moodLabels = [
    'Low',
    'Flat',
    'Steady',
    'Bright',
    'Radiant',
  ];
  static const _internalLabels = [
    'Panicked',
    'Uneasy',
    'Calm',
    'Focused',
    'Zen',
  ];

  @override
  Stream<HomeInsights> watchInsights() {
    return _entriesRepository.watchEntries().map(_compute);
  }

  HomeInsights _compute(List<JournalEntry> entries) {
    final baseline = _computeBaseline(entries);
    final observation = _computeObservation(entries);

    return HomeInsights(
      observationTitle: 'PATTERN IDENTIFIED',
      observationBody: observation ??
          'Write a few entries to unlock personalized observations.',
      baseline: baseline,
    );
  }

  EmotionalBaseline? _computeBaseline(List<JournalEntry> entries) {
    final evaluated = entries
        .where((e) =>
            e.energyIndex != null &&
            e.moodIndex != null &&
            e.internalIndex != null)
        .take(14)
        .toList();

    if (evaluated.length < 3) return null;

    double avgEnergy = 0;
    double avgMood = 0;
    double avgInternal = 0;
    for (final e in evaluated) {
      avgEnergy += e.energyIndex!;
      avgMood += e.moodIndex!;
      avgInternal += e.internalIndex!;
    }
    avgEnergy /= evaluated.length;
    avgMood /= evaluated.length;
    avgInternal /= evaluated.length;

    int idx(double v) => v.round().clamp(0, 4);

    final energyLabel = _energyLabels[idx(avgEnergy)];
    final moodLabel = _moodLabels[idx(avgMood)];
    final internalLabel = _internalLabels[idx(avgInternal)];

    final summary = 'Based on your last ${evaluated.length} check-ins, '
        'your baseline is $moodLabel with $internalLabel focus and $energyLabel energy.';

    return EmotionalBaseline(
      sampleSize: evaluated.length,
      energyLabel: energyLabel,
      moodLabel: moodLabel,
      internalLabel: internalLabel,
      summary: summary,
    );
  }

  String? _computeObservation(List<JournalEntry> entries) {
    if (entries.length < 3) return null;

    final recent = entries.take(20).toList();
    final buckets = <_TimeBucket, int>{};
    for (final e in recent) {
      final b = _bucketForHour(e.createdAt.hour);
      buckets[b] = (buckets[b] ?? 0) + 1;
    }
    if (buckets.isEmpty) return null;

    final best = buckets.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final pct = (best.value / math.max(1, recent.length) * 100).round();

    final label = switch (best.key) {
      _TimeBucket.morning => 'mornings',
      _TimeBucket.afternoon => 'afternoons',
      _TimeBucket.evening => 'evenings',
      _TimeBucket.night => 'late nights',
    };

    return 'Most of your recent entries happen in the $label ($pct%). '
        'Try keeping that time protected for reflection.';
  }
}

enum _TimeBucket { morning, afternoon, evening, night }

_TimeBucket _bucketForHour(int hour) {
  if (hour >= 5 && hour <= 11) return _TimeBucket.morning;
  if (hour >= 12 && hour <= 16) return _TimeBucket.afternoon;
  if (hour >= 17 && hour <= 20) return _TimeBucket.evening;
  return _TimeBucket.night;
}

