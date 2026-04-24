import 'package:flutter/material.dart'; // ✅ THIS IS THE FIX
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/analytics_models.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();

  factory NotificationsService() {
    return _instance;
  }

  NotificationsService._internal();

  static bool _isInitialized = false;

  // Initialize notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔵 [NOTIFICATIONS] Initializing...');

    try {
      await AwesomeNotifications().initialize(null, [
        NotificationChannel(
          channelKey: 'yakats_channel',
          channelName: 'YAKATS Alerts',
          channelDescription: 'Semptom uyarıları',
          defaultColor: const Color.fromARGB(255, 33, 150, 243),
          ledColor: const Color.fromARGB(255, 33, 150, 243),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
        ),
      ], debug: false);

      // Request permissions
      await AwesomeNotifications().requestPermissionToSendNotifications();

      _isInitialized = true;
      print('🟢 [NOTIFICATIONS] Initialized successfully');
    } catch (e) {
      print('🔴 [NOTIFICATIONS] Initialization error: $e');
    }
  }

  // Show low risk notification
  static Future<void> showLowRiskNotification() async {
    await _showNotification(
      id: 1,
      title: '✅ Düşük Risk',
      body: 'Semptom riski düşük. Güzel bir gün geçir!',
      color: const Color.fromARGB(255, 76, 175, 80),
    );
  }

  // Show medium risk notification
  static Future<void> showMediumRiskNotification(List<String> factors) async {
    final factorsText = factors.isEmpty
        ? 'İhtiyatlı ol'
        : factors.take(2).join(', ');

    await _showNotification(
      id: 2,
      title: '⚠️ Orta Seviye Risk',
      body: 'Risk tespit edildi: $factorsText',
      color: const Color.fromARGB(255, 255, 193, 7),
    );
  }

  // Show high risk notification
  static Future<void> showHighRiskNotification(List<String> factors) async {
    final factorsText = factors.isEmpty
        ? 'Tedbirler alın'
        : factors.take(2).join(', ');

    await _showNotification(
      id: 3,
      title: '🔶 YÜKSEK RİSK!',
      body: 'Acil önlem gerekli: $factorsText. İlaçlarınızı kontrol edin!',
      color: const Color.fromARGB(255, 255, 111, 0),
    );
  }

  // Show critical risk notification
  static Future<void> showCriticalRiskNotification(List<String> factors) async {
    final factorsText = factors.isEmpty
        ? 'Acil yardım arayın'
        : factors.take(2).join(', ');

    await _showNotification(
      id: 4,
      title: '🚨 CRİTİK RİSK!',
      body: 'ACIL: $factorsText. Doktor ile iletişim kurun!',
      color: const Color.fromARGB(255, 244, 67, 54),
    );
  }

  // Generic notification
  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required Color color,
  }) async {
    try {
      print('🔵 [NOTIFICATIONS] Showing: $title');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'yakats_channel',
          title: title,
          body: body,
          color: color,
          payload: {'risk': title},
          notificationLayout: NotificationLayout.Default,
        ),
      );

      print('🟢 [NOTIFICATIONS] Shown successfully');
    } catch (e) {
      print('🔴 [NOTIFICATIONS] Error: $e');
    }
  }

  // Show risk-based notification
  static Future<void> showRiskNotification(RiskAssessment risk) async {
    if (risk.riskLevel == 'DÜŞÜK') {
      await showLowRiskNotification();
    } else if (risk.riskLevel == 'ORTA') {
      await showMediumRiskNotification(risk.factors);
    } else if (risk.riskLevel == 'YÜKSEK') {
      await showHighRiskNotification(risk.factors);
    } else if (risk.riskLevel == 'CRİTİK') {
      await showCriticalRiskNotification(risk.factors);
    }
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().dismiss(id);
    print('🟢 [NOTIFICATIONS] Canceled notification: $id');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().dismissAllNotifications();
    print('🟢 [NOTIFICATIONS] Canceled all notifications');
  }
}
