import '../domain/home_insights.dart';
import '../domain/home_insights_service.dart';

class MockHomeInsightsService implements HomeInsightsService {
  const MockHomeInsightsService();

  @override
  Stream<HomeInsights> watchInsights() {
    return Stream.value(
      const HomeInsights(
        observationTitle: 'PATTERN IDENTIFIED',
        observationBody:
            'You seem to find the most clarity after evening walks. Consider extending these sessions.',
        baseline: EmotionalBaseline(
          sampleSize: 7,
          energyLabel: 'Energetic',
          moodLabel: 'Steady',
          internalLabel: 'Focused',
          summary:
              'Your baseline is steady and focused with a slightly elevated energy level.',
        ),
      ),
    );
  }
}

