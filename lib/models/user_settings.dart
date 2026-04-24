class UserSettings {
  final bool enableAlerts;
  final double riskThreshold;
  final bool notifyOnHighRisk;
  final bool notifyOnMediumRisk;
  final bool checkWeather;
  final bool checkLocation;
  final bool checkTime;
  final int monitoringInterval;
  final bool enableBackgroundMonitoring;

  UserSettings({
    this.enableAlerts = true,
    this.riskThreshold = 50.0,
    this.notifyOnHighRisk = true,
    this.notifyOnMediumRisk = true,
    this.checkWeather = true,
    this.checkLocation = true,
    this.checkTime = true,
    this.monitoringInterval = 15, // minutes
    this.enableBackgroundMonitoring = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'enableAlerts': enableAlerts,
      'riskThreshold': riskThreshold,
      'notifyOnHighRisk': notifyOnHighRisk,
      'notifyOnMediumRisk': notifyOnMediumRisk,
      'checkWeather': checkWeather,
      'checkLocation': checkLocation,
      'checkTime': checkTime,
      'monitoringInterval': monitoringInterval,
      'enableBackgroundMonitoring': enableBackgroundMonitoring,
    };
  }

  static UserSettings fromMap(Map<String, dynamic> map) {
    return UserSettings(
      enableAlerts: map['enableAlerts'] ?? true,
      riskThreshold: (map['riskThreshold'] ?? 50.0).toDouble(),
      notifyOnHighRisk: map['notifyOnHighRisk'] ?? true,
      notifyOnMediumRisk: map['notifyOnMediumRisk'] ?? true,
      checkWeather: map['checkWeather'] ?? true,
      checkLocation: map['checkLocation'] ?? true,
      checkTime: map['checkTime'] ?? true,
      monitoringInterval: map['monitoringInterval'] ?? 15,
      enableBackgroundMonitoring: map['enableBackgroundMonitoring'] ?? false,
    );
  }

  UserSettings copyWith({
    bool? enableAlerts,
    double? riskThreshold,
    bool? notifyOnHighRisk,
    bool? notifyOnMediumRisk,
    bool? checkWeather,
    bool? checkLocation,
    bool? checkTime,
    int? monitoringInterval,
    bool? enableBackgroundMonitoring,
  }) {
    return UserSettings(
      enableAlerts: enableAlerts ?? this.enableAlerts,
      riskThreshold: riskThreshold ?? this.riskThreshold,
      notifyOnHighRisk: notifyOnHighRisk ?? this.notifyOnHighRisk,
      notifyOnMediumRisk: notifyOnMediumRisk ?? this.notifyOnMediumRisk,
      checkWeather: checkWeather ?? this.checkWeather,
      checkLocation: checkLocation ?? this.checkLocation,
      checkTime: checkTime ?? this.checkTime,
      monitoringInterval: monitoringInterval ?? this.monitoringInterval,
      enableBackgroundMonitoring:
          enableBackgroundMonitoring ?? this.enableBackgroundMonitoring,
    );
  }
}
