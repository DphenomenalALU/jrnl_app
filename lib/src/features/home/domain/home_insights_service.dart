import 'home_insights.dart';

abstract interface class HomeInsightsService {
  Stream<HomeInsights> watchInsights();
}

