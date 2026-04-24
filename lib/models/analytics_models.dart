class TriggerFactor {
  final String name;
  final String type; // 'weather', 'location', 'time', 'combined'
  final double confidence; // 0.0 to 1.0
  final String description;
  final List<String> evidence;

  TriggerFactor({
    required this.name,
    required this.type,
    required this.confidence,
    required this.description,
    required this.evidence,
  });
}

class RiskAssessment {
  final double riskScore; // 0 to 100
  final String riskLevel; // 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL'
  final List<String> factors; // Reasons for the risk
  final DateTime assessmentTime;

  RiskAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.factors,
    required this.assessmentTime,
  });
}

class TriggerAnalysis {
  final List<TriggerFactor> triggers;
  final Map<String, dynamic> statistics;
  final DateTime analysisTime;
  final int symptomCount;

  TriggerAnalysis({
    required this.triggers,
    required this.statistics,
    required this.analysisTime,
    required this.symptomCount,
  });
}

class SymptomStatistics {
  final int totalSymptoms;
  final double averageSeverity;
  final int mildCount;
  final int moderateCount;
  final int severeCount;
  final String mostCommonSymptom;
  final List<int> severityByHour;
  final List<int> severityByDay;

  SymptomStatistics({
    required this.totalSymptoms,
    required this.averageSeverity,
    required this.mildCount,
    required this.moderateCount,
    required this.severeCount,
    required this.mostCommonSymptom,
    required this.severityByHour,
    required this.severityByDay,
  });
}

class WeatherTriggerData {
  final double? temperatureThreshold;
  final double? humidityThreshold;
  final double? windSpeedThreshold;
  final List<String> weatherConditions;
  final Map<String, double> temperatureCorrelation;
  final Map<String, double> humidityCorrelation;

  WeatherTriggerData({
    required this.temperatureThreshold,
    required this.humidityThreshold,
    required this.windSpeedThreshold,
    required this.weatherConditions,
    required this.temperatureCorrelation,
    required this.humidityCorrelation,
  });
}

class LocationTriggerData {
  final List<String> triggerLocations;
  final Map<String, int> locationFrequency;
  final Map<String, double> locationSeverity;

  LocationTriggerData({
    required this.triggerLocations,
    required this.locationFrequency,
    required this.locationSeverity,
  });
}

class TimeTriggerData {
  final List<int> riskyHours; // 0-23
  final List<int> riskyDays; // 0-6 (Monday-Sunday)
  final Map<int, double> hourlyRisk;
  final Map<int, double> dailyRisk;

  TimeTriggerData({
    required this.riskyHours,
    required this.riskyDays,
    required this.hourlyRisk,
    required this.dailyRisk,
  });
}
