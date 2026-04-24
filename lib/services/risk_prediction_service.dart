import 'package:flutter/material.dart';
import '../models/analytics_models.dart';
import '../models/symptom_log.dart';
import 'analytics_service.dart';
import 'location_service.dart';
import 'weather_service.dart';

class RiskPredictionService {
  // Singleton pattern
  static final RiskPredictionService _instance =
      RiskPredictionService._internal();

  factory RiskPredictionService() {
    return _instance;
  }

  RiskPredictionService._internal();

  // Calculate real-time risk based on current conditions and historical data
  static Future<RiskAssessment> calculateRealTimeRisk(
    List<SymptomLog> allSymptoms,
  ) async {
    try {
      print('🔵 [RISK] Starting real-time risk calculation...');

      // Get current conditions
      final location = await LocationService.getCurrentLocation();
      final weather = location != null
          ? await WeatherService.getWeather(
              location['latitude'] as double,
              location['longitude'] as double,
            )
          : null;

      // Perform trigger analysis
      final analysis = AnalyticsService.analyzeTriggers(allSymptoms);

      // Calculate risk
      final risk = AnalyticsService.calculateCurrentRisk(
        analysis,
        weather?.temperature,
        weather?.humidity,
        weather?.weatherCondition,
        location?['locationName'] as String?,
        DateTime.now(),
      );

      print('🟢 [RISK] Risk calculation complete: ${risk.riskLevel}');
      return risk;
    } catch (e) {
      print('🔴 [RISK] Error calculating risk: $e');
      return RiskAssessment(
        riskScore: 0,
        riskLevel: 'UNKNOWN',
        factors: ['Error calculating risk'],
        assessmentTime: DateTime.now(),
      );
    }
  }

  // Get risk level color
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return Colors.green;
      case 'ORTA':
        return Colors.orange;
      case 'YÜKSEK':
        return Colors.deepOrange;
      case 'CRİTİK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get risk level icon
  static IconData getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return Icons.sentiment_satisfied;
      case 'ORTA':
        return Icons.sentiment_neutral;
      case 'YÜKSEK':
        return Icons.warning;
      case 'CRİTİK':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  // Get risk level emoji
  static String getRiskEmoji(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return '✅';
      case 'ORTA':
        return '⚠️';
      case 'YÜKSEK':
        return '🔶';
      case 'CRİTİK':
        return '🚨';
      default:
        return '❓';
    }
  }

  // Get risk description
  static String getRiskDescription(String riskLevel) {
    switch (riskLevel) {
      case 'DÜŞÜK':
        return 'Semptom riski düşük. Endişelenmeyin!';
      case 'ORTA':
        return 'Orta seviye risk. İhtiyatlı olun.';
      case 'YÜKSEK':
        return 'Yüksek risk! İlaçlarınızı yanınızda bulundurun.';
      case 'CRİTİK':
        return 'CRİTİK! Acil önlemler alın.';
      default:
        return 'Risk seviyesi bilinmiyor.';
    }
  }

  // Determine if an alert should be shown
  static bool shouldShowAlert(String riskLevel) {
    return riskLevel == 'YÜKSEK' || riskLevel == 'CRİTİK';
  }
}
