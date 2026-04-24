class SymptomLog {
  final int? id;
  final String symptomType;
  final int severity;
  final String notes;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  final String? locationName;

  // NEW - Weather fields
  final double? temperature;
  final double? humidity;
  final double? windSpeed;
  final String? weatherCondition;

  SymptomLog({
    this.id,
    required this.symptomType,
    required this.severity,
    required this.notes,
    required this.dateTime,
    this.latitude,
    this.longitude,
    this.locationName,
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.weatherCondition,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'symptomType': symptomType,
      'severity': severity,
      'notes': notes,
      'dateTime': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'weatherCondition': weatherCondition,
    };
  }

  // Create from database Map
  static SymptomLog fromMap(Map<String, dynamic> map) {
    return SymptomLog(
      id: map['id'],
      symptomType: map['symptomType'],
      severity: map['severity'],
      notes: map['notes'],
      dateTime: DateTime.parse(map['dateTime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      locationName: map['locationName'],
      temperature: map['temperature'],
      humidity: map['humidity'],
      windSpeed: map['windSpeed'],
      weatherCondition: map['weatherCondition'],
    );
  }
}
