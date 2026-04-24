class AlertLog {
  final int? id;
  final DateTime dateTime;
  final String title;
  final String message;
  final double riskScore;
  final String riskLevel;
  final List<String> triggers;
  final bool isRead;

  AlertLog({
    this.id,
    required this.dateTime,
    required this.title,
    required this.message,
    required this.riskScore,
    required this.riskLevel,
    required this.triggers,
    this.isRead = false,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'title': title,
      'message': message,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'triggers': triggers.join('|'),
      'isRead': isRead ? 1 : 0,
    };
  }

  // Create from database Map
  static AlertLog fromMap(Map<String, dynamic> map) {
    return AlertLog(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      title: map['title'],
      message: map['message'],
      riskScore: map['riskScore'],
      riskLevel: map['riskLevel'],
      triggers: (map['triggers'] as String).split('|'),
      isRead: map['isRead'] == 1,
    );
  }
}
