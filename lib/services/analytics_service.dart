import '../models/symptom_log.dart';
import '../models/analytics_models.dart';
import 'dart:math';

class AnalyticsService {
  // Analyze all symptoms and find triggers
  static TriggerAnalysis analyzeTriggers(List<SymptomLog> symptoms) {
    print(
      '🔵 [ANALYTICS] Starting trigger analysis on ${symptoms.length} symptoms...',
    );

    if (symptoms.isEmpty) {
      print('🟠 [ANALYTICS] No symptoms to analyze');
      return TriggerAnalysis(
        triggers: [],
        statistics: {},
        analysisTime: DateTime.now(),
        symptomCount: 0,
      );
    }

    try {
      // Get basic statistics
      final stats = calculateStatistics(symptoms);

      // Analyze each trigger type
      final weatherTriggers = _analyzeWeatherTriggers(symptoms);
      final locationTriggers = _analyzeLocationTriggers(symptoms);
      final timeTriggers = _analyzeTimeTriggers(symptoms);

      // Combine all triggers
      final allTriggers = <TriggerFactor>[
        ..._convertWeatherTriggers(weatherTriggers),
        ..._convertLocationTriggers(locationTriggers),
        ..._convertTimeTriggers(timeTriggers),
      ];

      // Sort by confidence
      allTriggers.sort((a, b) => b.confidence.compareTo(a.confidence));

      print('🟢 [ANALYTICS] Found ${allTriggers.length} triggers');

      return TriggerAnalysis(
        triggers: allTriggers,
        statistics: {
          'totalSymptoms': stats.totalSymptoms,
          'averageSeverity': stats.averageSeverity,
          'mildCount': stats.mildCount,
          'moderateCount': stats.moderateCount,
          'severeCount': stats.severeCount,
          'mostCommonSymptom': stats.mostCommonSymptom,
        },
        analysisTime: DateTime.now(),
        symptomCount: symptoms.length,
      );
    } catch (e) {
      print('🔴 [ANALYTICS] Error analyzing triggers: $e');
      return TriggerAnalysis(
        triggers: [],
        statistics: {},
        analysisTime: DateTime.now(),
        symptomCount: symptoms.length,
      );
    }
  }

  // Calculate basic statistics - NOW PUBLIC (no underscore)
  static SymptomStatistics calculateStatistics(List<SymptomLog> symptoms) {
    int totalSymptoms = symptoms.length;
    double totalSeverity = symptoms.fold(0, (sum, s) => sum + s.severity);
    double averageSeverity = totalSeverity / totalSymptoms;

    int mildCount = symptoms.where((s) => s.severity <= 3).length;
    int moderateCount = symptoms
        .where((s) => s.severity > 3 && s.severity <= 6)
        .length;
    int severeCount = symptoms.where((s) => s.severity > 6).length;

    // Find most common symptom
    Map<String, int> symptomFrequency = {};
    for (var symptom in symptoms) {
      symptomFrequency[symptom.symptomType] =
          (symptomFrequency[symptom.symptomType] ?? 0) + 1;
    }
    String mostCommon = symptomFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Severity by hour
    List<int> severityByHour = List.filled(24, 0);
    List<int> countByHour = List.filled(24, 0);
    for (var symptom in symptoms) {
      int hour = symptom.dateTime.hour;
      severityByHour[hour] += symptom.severity;
      countByHour[hour]++;
    }
    for (int i = 0; i < 24; i++) {
      if (countByHour[i] > 0) {
        severityByHour[i] = (severityByHour[i] / countByHour[i]).round();
      }
    }

    // Severity by day of week
    List<int> severityByDay = List.filled(7, 0);
    List<int> countByDay = List.filled(7, 0);
    for (var symptom in symptoms) {
      int day = symptom.dateTime.weekday - 1; // 0 = Monday
      severityByDay[day] += symptom.severity;
      countByDay[day]++;
    }
    for (int i = 0; i < 7; i++) {
      if (countByDay[i] > 0) {
        severityByDay[i] = (severityByDay[i] / countByDay[i]).round();
      }
    }

    return SymptomStatistics(
      totalSymptoms: totalSymptoms,
      averageSeverity: averageSeverity,
      mildCount: mildCount,
      moderateCount: moderateCount,
      severeCount: severeCount,
      mostCommonSymptom: mostCommon,
      severityByHour: severityByHour,
      severityByDay: severityByDay,
    );
  }

  // Analyze weather as trigger
  static WeatherTriggerData _analyzeWeatherTriggers(List<SymptomLog> symptoms) {
    // Filter symptoms with weather data
    final withWeather = symptoms.where((s) => s.temperature != null).toList();

    if (withWeather.isEmpty) {
      return WeatherTriggerData(
        temperatureThreshold: null,
        humidityThreshold: null,
        windSpeedThreshold: null,
        weatherConditions: [],
        temperatureCorrelation: {},
        humidityCorrelation: {},
      );
    }

    // Analyze temperature correlation
    final temps = withWeather.map((s) => s.temperature!).toList();
    final severities = withWeather.map((s) => s.severity).toList();

    double tempCorrelation = _calculatePearsonCorrelation(temps, severities);

    // Find temperature threshold (where symptoms spike)
    double? tempThreshold = _findThreshold(withWeather, 'temperature');

    // Analyze humidity correlation
    final withHumidity = withWeather.where((s) => s.humidity != null).toList();
    double? humidityThreshold;
    if (withHumidity.isNotEmpty) {
      humidityThreshold = _findThreshold(withHumidity, 'humidity');
    }

    // Weather conditions
    final weatherConditions = withWeather
        .where((s) => s.weatherCondition != null)
        .map((s) => s.weatherCondition!)
        .toSet()
        .toList();

    return WeatherTriggerData(
      temperatureThreshold: tempThreshold,
      humidityThreshold: humidityThreshold,
      windSpeedThreshold: null,
      weatherConditions: weatherConditions,
      temperatureCorrelation: {'correlation': tempCorrelation},
      humidityCorrelation: {},
    );
  }

  // Analyze location as trigger
  static LocationTriggerData _analyzeLocationTriggers(
    List<SymptomLog> symptoms,
  ) {
    final withLocation = symptoms.where((s) => s.locationName != null).toList();

    if (withLocation.isEmpty) {
      return LocationTriggerData(
        triggerLocations: [],
        locationFrequency: {},
        locationSeverity: {},
      );
    }

    // Count location frequency
    Map<String, int> locationFrequency = {};
    Map<String, List<int>> locationSeverities = {};

    for (var symptom in withLocation) {
      final location = symptom.locationName!;
      locationFrequency[location] = (locationFrequency[location] ?? 0) + 1;
      locationSeverities[location] ??= [];
      locationSeverities[location]!.add(symptom.severity);
    }

    // Calculate average severity per location
    Map<String, double> locationSeverity = {};
    locationSeverities.forEach((location, severities) {
      double avg = severities.reduce((a, b) => a + b) / severities.length;
      locationSeverity[location] = avg;
    });

    // Find trigger locations (high frequency and high severity)
    List<String> triggerLocations = locationFrequency.entries
        .where((e) => e.value >= 2 && locationSeverity[e.key]! >= 5)
        .map((e) => e.key)
        .toList();

    return LocationTriggerData(
      triggerLocations: triggerLocations,
      locationFrequency: locationFrequency,
      locationSeverity: locationSeverity,
    );
  }

  // Analyze time as trigger
  static TimeTriggerData _analyzeTimeTriggers(List<SymptomLog> symptoms) {
    List<int> severityByHour = List.filled(24, 0);
    List<int> countByHour = List.filled(24, 0);
    List<int> severityByDay = List.filled(7, 0);
    List<int> countByDay = List.filled(7, 0);

    for (var symptom in symptoms) {
      int hour = symptom.dateTime.hour;
      int day = symptom.dateTime.weekday - 1;

      severityByHour[hour] += symptom.severity;
      countByHour[hour]++;
      severityByDay[day] += symptom.severity;
      countByDay[day]++;
    }

    // Calculate average severity per hour and day
    Map<int, double> hourlyRisk = {};
    Map<int, double> dailyRisk = {};

    for (int i = 0; i < 24; i++) {
      if (countByHour[i] > 0) {
        hourlyRisk[i] = (severityByHour[i] / countByHour[i]).toDouble();
      }
    }

    for (int i = 0; i < 7; i++) {
      if (countByDay[i] > 0) {
        dailyRisk[i] = (severityByDay[i] / countByDay[i]).toDouble();
      }
    }

    // Find risky hours and days (above average)
    double avgHourlyRisk = hourlyRisk.isEmpty
        ? 0
        : hourlyRisk.values.reduce((a, b) => a + b) / hourlyRisk.length;
    double avgDailyRisk = dailyRisk.isEmpty
        ? 0
        : dailyRisk.values.reduce((a, b) => a + b) / dailyRisk.length;

    List<int> riskyHours = hourlyRisk.entries
        .where((e) => e.value > avgHourlyRisk)
        .map((e) => e.key)
        .toList();

    List<int> riskyDays = dailyRisk.entries
        .where((e) => e.value > avgDailyRisk)
        .map((e) => e.key)
        .toList();

    return TimeTriggerData(
      riskyHours: riskyHours,
      riskyDays: riskyDays,
      hourlyRisk: hourlyRisk,
      dailyRisk: dailyRisk,
    );
  }

  // Convert weather triggers to TriggerFactor
  static List<TriggerFactor> _convertWeatherTriggers(WeatherTriggerData data) {
    final triggers = <TriggerFactor>[];

    if (data.temperatureThreshold != null) {
      triggers.add(
        TriggerFactor(
          name: 'Sıcaklık',
          type: 'weather',
          confidence: 0.75,
          description:
              '${data.temperatureThreshold!.toStringAsFixed(0)}°C üzerinde',
          evidence: ['Symptom data analysis', 'Weather correlation'],
        ),
      );
    }

    if (data.humidityThreshold != null) {
      triggers.add(
        TriggerFactor(
          name: 'Nem',
          type: 'weather',
          confidence: 0.72,
          description:
              '%${data.humidityThreshold!.toStringAsFixed(0)} üzerinde',
          evidence: ['Humidity analysis', 'Past patterns'],
        ),
      );
    }

    return triggers;
  }

  // Convert location triggers to TriggerFactor
  static List<TriggerFactor> _convertLocationTriggers(
    LocationTriggerData data,
  ) {
    final triggers = <TriggerFactor>[];

    for (var location in data.triggerLocations) {
      final severity = data.locationSeverity[location] ?? 0;
      final frequency = data.locationFrequency[location] ?? 0;
      final confidence = (severity / 10.0) * (frequency / 10.0).clamp(0, 1);

      triggers.add(
        TriggerFactor(
          name: 'Konum: $location',
          type: 'location',
          confidence: confidence.clamp(0, 1),
          description:
              '$frequency kez, ort. şiddet: ${severity.toStringAsFixed(1)}',
          evidence: ['Location frequency', 'Severity analysis'],
        ),
      );
    }

    return triggers;
  }

  // Convert time triggers to TriggerFactor
  static List<TriggerFactor> _convertTimeTriggers(TimeTriggerData data) {
    final triggers = <TriggerFactor>[];

    if (data.riskyHours.isNotEmpty) {
      final hours = data.riskyHours.map((h) => '$h:00').join(', ');
      triggers.add(
        TriggerFactor(
          name: 'Zaman: Riskli Saatler',
          type: 'time',
          confidence: 0.70,
          description: 'Saatler: $hours',
          evidence: ['Time-based analysis', 'Pattern detection'],
        ),
      );
    }

    if (data.riskyDays.isNotEmpty) {
      final dayNames = [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ];
      final days = data.riskyDays.map((d) => dayNames[d]).join(', ');
      triggers.add(
        TriggerFactor(
          name: 'Zaman: Riskli Günler',
          type: 'time',
          confidence: 0.68,
          description: 'Günler: $days',
          evidence: ['Weekly pattern', 'Historical data'],
        ),
      );
    }

    return triggers;
  }

  // Helper: Calculate Pearson correlation coefficient
  static double _calculatePearsonCorrelation(List<double> x, List<int> y) {
    if (x.length != y.length || x.isEmpty) return 0.0;

    double meanX = x.reduce((a, b) => a + b) / x.length;
    double meanY = y.reduce((a, b) => a + b) / y.length;

    double numerator = 0;
    double denominatorX = 0;
    double denominatorY = 0;

    for (int i = 0; i < x.length; i++) {
      double dx = x[i] - meanX;
      double dy = (y[i] - meanY).toDouble();

      numerator += dx * dy;
      denominatorX += dx * dx;
      denominatorY += dy * dy;
    }

    double denominator = sqrt(denominatorX * denominatorY);
    if (denominator == 0) return 0.0;

    return (numerator / denominator).abs().clamp(0, 1);
  }

  // Helper: Find threshold where symptoms spike
  static double? _findThreshold(List<SymptomLog> symptoms, String type) {
    List<double> values = [];
    List<int> severities = [];

    for (var symptom in symptoms) {
      double? value;
      if (type == 'temperature') {
        value = symptom.temperature;
      } else if (type == 'humidity') {
        value = symptom.humidity;
      }

      if (value != null) {
        values.add(value);
        severities.add(symptom.severity);
      }
    }

    if (values.isEmpty) return null;

    // Sort by value
    final paired = List.generate(
      values.length,
      (i) => (values[i], severities[i]),
    );
    paired.sort((a, b) => a.$1.compareTo(b.$1));

    // Find point where severity increases significantly
    double? threshold;
    double maxIncrease = 0;

    for (int i = 1; i < paired.length; i++) {
      double increase =
          paired[i].$2.toDouble() - (i > 0 ? paired[i - 1].$2.toDouble() : 0.0);
      if (increase > maxIncrease) {
        maxIncrease = increase;
        threshold = paired[i].$1;
      }
    }

    return threshold;
  }

  // Calculate current risk based on real-time conditions
  static RiskAssessment calculateCurrentRisk(
    TriggerAnalysis analysis,
    double? currentTemp,
    double? currentHumidity,
    String? currentWeather,
    String? currentLocation,
    DateTime currentTime,
  ) {
    print('🔵 [RISK] Calculating current risk...');

    double riskScore = 0;
    List<String> factors = [];

    // Check each trigger
    for (var trigger in analysis.triggers) {
      if (trigger.type == 'weather') {
        if (trigger.name.contains('Sıcaklık') && currentTemp != null) {
          // Extract threshold from description
          if (trigger.description.contains('>') ||
              trigger.description.contains('üzerinde')) {
            final parts = trigger.description.split('°');
            if (parts.isNotEmpty) {
              final thresholdStr = parts[0].replaceAll(RegExp(r'[^0-9.]'), '');
              final threshold = double.tryParse(thresholdStr) ?? 0;
              if (currentTemp > threshold) {
                riskScore += trigger.confidence * 30;
                factors.add('Sıcaklık: ${currentTemp.toStringAsFixed(1)}°C');
              }
            }
          }
        }

        if (trigger.name.contains('Nem') && currentHumidity != null) {
          final parts = trigger.description.split('%');
          if (parts.isNotEmpty) {
            final thresholdStr = parts[0].replaceAll(RegExp(r'[^0-9.]'), '');
            final threshold = double.tryParse(thresholdStr) ?? 0;
            if (currentHumidity > threshold) {
              riskScore += trigger.confidence * 30;
              factors.add('Nem: ${currentHumidity.toStringAsFixed(0)}%');
            }
          }
        }
      }

      if (trigger.type == 'location' && currentLocation != null) {
        if (trigger.description.contains(currentLocation)) {
          riskScore += trigger.confidence * 25;
          factors.add('Konum: $currentLocation');
        }
      }

      if (trigger.type == 'time') {
        if (trigger.name.contains('Saatler')) {
          if (trigger.description.contains('${currentTime.hour}:')) {
            riskScore += trigger.confidence * 20;
            factors.add('Saat: ${currentTime.hour}:00');
          }
        }

        if (trigger.name.contains('Günler')) {
          final dayNames = [
            'Pazartesi',
            'Salı',
            'Çarşamba',
            'Perşembe',
            'Cuma',
            'Cumartesi',
            'Pazar',
          ];
          if (trigger.description.contains(dayNames[currentTime.weekday - 1])) {
            riskScore += trigger.confidence * 20;
            factors.add('Gün: ${dayNames[currentTime.weekday - 1]}');
          }
        }
      }
    }

    riskScore = riskScore.clamp(0, 100);

    String riskLevel;
    if (riskScore >= 75) {
      riskLevel = 'CRİTİK';
    } else if (riskScore >= 50) {
      riskLevel = 'YÜKSEK';
    } else if (riskScore >= 25) {
      riskLevel = 'ORTA';
    } else {
      riskLevel = 'DÜŞÜK';
    }

    print('🟢 [RISK] Risk score: ${riskScore.toStringAsFixed(1)} ($riskLevel)');

    return RiskAssessment(
      riskScore: riskScore,
      riskLevel: riskLevel,
      factors: factors,
      assessmentTime: currentTime,
    );
  }
}
