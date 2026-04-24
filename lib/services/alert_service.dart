import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_log.dart';
import '../models/user_settings.dart';
import '../models/analytics_models.dart'; // ← duplicate removed, kept once
import '../services/analytics_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  Timer? _monitoringTimer;
  UserSettings _settings = UserSettings();
  bool _isMonitoring = false;

  // Initialize the service
  Future<void> initialize() async {
    await _loadSettings();
    await _initializeNotifications();
    print('🟢 [ALERT] Service initialized');
  }

  // Load user settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsMap = {
        'enableAlerts': prefs.getBool('enableAlerts') ?? true,
        'riskThreshold': prefs.getDouble('riskThreshold') ?? 50.0,
        'notifyOnHighRisk': prefs.getBool('notifyOnHighRisk') ?? true,
        'notifyOnMediumRisk': prefs.getBool('notifyOnMediumRisk') ?? true,
        'checkWeather': prefs.getBool('checkWeather') ?? true,
        'checkLocation': prefs.getBool('checkLocation') ?? true,
        'checkTime': prefs.getBool('checkTime') ?? true,
        'monitoringInterval': prefs.getInt('monitoringInterval') ?? 15,
        'enableBackgroundMonitoring':
            prefs.getBool('enableBackgroundMonitoring') ?? false,
      };
      _settings = UserSettings.fromMap(settingsMap);
      print('🟢 [ALERT] Settings loaded');
    } catch (e) {
      print('🔴 [ALERT] Error loading settings: $e');
    }
  }

  // Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    try {
      _settings = settings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enableAlerts', settings.enableAlerts);
      await prefs.setDouble('riskThreshold', settings.riskThreshold);
      await prefs.setBool('notifyOnHighRisk', settings.notifyOnHighRisk);
      await prefs.setBool('notifyOnMediumRisk', settings.notifyOnMediumRisk);
      await prefs.setBool('checkWeather', settings.checkWeather);
      await prefs.setBool('checkLocation', settings.checkLocation);
      await prefs.setBool('checkTime', settings.checkTime);
      await prefs.setInt('monitoringInterval', settings.monitoringInterval);
      await prefs.setBool(
        'enableBackgroundMonitoring',
        settings.enableBackgroundMonitoring,
      );
      print('🟢 [ALERT] Settings saved');
    } catch (e) {
      print('🔴 [ALERT] Error saving settings: $e');
    }
  }

  // Get current settings
  UserSettings getSettings() => _settings;

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'risk_alerts',
        channelName: 'Risk Alerts',
        channelDescription: 'Allergy risk notifications',
        defaultColor: Colors.red,
        ledColor: Colors.red,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
      ),
      NotificationChannel(
        channelKey: 'reminders',
        channelName: 'Reminders',
        channelDescription: 'Daily reminders',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        importance: NotificationImportance.Default,
        channelShowBadge: true,
      ),
    ]);
  }

  // Start monitoring
  Future<void> startMonitoring() async {
    if (!_settings.enableAlerts || _isMonitoring) return;

    _isMonitoring = true;
    print('🟢 [ALERT] Started monitoring');

    await _checkAndNotify();

    final interval = Duration(minutes: _settings.monitoringInterval);
    _monitoringTimer = Timer.periodic(interval, (_) async {
      await _checkAndNotify();
    });
  }

  // Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _isMonitoring = false;
    print('🟢 [ALERT] Stopped monitoring');
  }

  // Check conditions and send notification if needed
  Future<void> _checkAndNotify() async {
    print('🔵 [ALERT] Checking conditions...');

    try {
      final locationData = await LocationService.getCurrentLocation();
      if (locationData == null) {
        print('🟠 [ALERT] Could not get location');
        return;
      }

      final weatherData = await WeatherService.getWeather(
        locationData['latitude']!,
        locationData['longitude']!,
      );

      final db = DatabaseHelper.instance;
      final allSymptoms = await db.getAllSymptoms();

      if (allSymptoms.isEmpty) {
        print('🟠 [ALERT] No symptoms to analyze');
        return;
      }

      final analysis = AnalyticsService.analyzeTriggers(allSymptoms);

      final riskAssessment = AnalyticsService.calculateCurrentRisk(
        analysis,
        weatherData?.temperature,
        weatherData?.humidity,
        weatherData?.weatherCondition,
        locationData['locationName'],
        DateTime.now(),
      );

      print('🔵 [ALERT] Current risk: ${riskAssessment.riskScore}%');

      if (_shouldNotify(riskAssessment)) {
        await _sendNotification(riskAssessment);
        await _logAlert(riskAssessment);
      }
    } catch (e) {
      print('🔴 [ALERT] Error checking conditions: $e');
    }
  }

  // Determine if we should send notification
  bool _shouldNotify(RiskAssessment risk) {
    if (!_settings.enableAlerts) return false;

    if (risk.riskLevel == 'CRİTİK' && _settings.notifyOnHighRisk) {
      return risk.riskScore >= _settings.riskThreshold;
    }
    if (risk.riskLevel == 'YÜKSEK' && _settings.notifyOnHighRisk) {
      return risk.riskScore >= _settings.riskThreshold;
    }
    if (risk.riskLevel == 'ORTA' && _settings.notifyOnMediumRisk) {
      return risk.riskScore >= _settings.riskThreshold;
    }

    return false;
  }

  // Send notification
  Future<void> _sendNotification(RiskAssessment risk) async {
    final title = _getNotificationTitle(risk.riskLevel);
    final message = _getNotificationMessage(risk);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'risk_alerts',
        title: title,
        body: message,
        notificationLayout: NotificationLayout.BigText,
        color: _getNotificationColor(risk.riskLevel),
        locked: true,
        autoDismissible: false,
      ),
    );

    print('🟢 [ALERT] Notification sent: $title');
  }

  // Log alert to database
  Future<void> _logAlert(RiskAssessment risk) async {
    final alert = AlertLog(
      dateTime: DateTime.now(),
      title: _getNotificationTitle(risk.riskLevel),
      message: _getNotificationMessage(risk),
      riskScore: risk.riskScore,
      riskLevel: risk.riskLevel,
      triggers: risk.factors,
    );

    final db = DatabaseHelper.instance;
    await db.insertAlert(alert);
    print('🟢 [ALERT] Alert logged to database');
  }

  // Helper methods
  String _getNotificationTitle(String riskLevel) {
    switch (riskLevel) {
      case 'CRİTİK':
        return '🚨 KRİTİK RİSK UYARISI!';
      case 'YÜKSEK':
        return '⚠️ YÜKSEK RİSK UYARISI';
      case 'ORTA':
        return '📊 ORTA RİSK TESPİTİ';
      default:
        return 'RİSK TESPİTİ';
    }
  }

  String _getNotificationMessage(RiskAssessment risk) {
    final factors = risk.factors.take(3).join(', ');
    return 'Risk seviyeniz: %${risk.riskScore.toStringAsFixed(0)} (${risk.riskLevel})\nTetikleyiciler: $factors';
  }

  Color _getNotificationColor(String riskLevel) {
    switch (riskLevel) {
      case 'CRİTİK':
        return Colors.red;
      case 'YÜKSEK':
        return Colors.orange;
      case 'ORTA':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }

  // Get all alerts
  Future<List<AlertLog>> getAlerts() async {
    final db = DatabaseHelper.instance;
    return await db.getAllAlerts();
  }

  // Get unread alerts count
  Future<int> getUnreadCount() async {
    final db = DatabaseHelper.instance;
    final unread = await db.getUnreadAlerts();
    return unread.length;
  }

  // Mark alert as read
  Future<void> markAsRead(int alertId) async {
    final db = DatabaseHelper.instance;
    await db.markAlertAsRead(alertId);
  }

  // Mark all alerts as read
  Future<void> markAllAsRead() async {
    final db = DatabaseHelper.instance;
    await db.markAllAlertsAsRead();
  }

  // Delete single alert ← THIS WAS MISSING
  Future<void> deleteAlert(int alertId) async {
    final db = DatabaseHelper.instance;
    await db.deleteAlert(alertId);
    print('🟢 [ALERT] Alert deleted: $alertId');
  }

  // Delete all alerts
  Future<void> clearAllAlerts() async {
    final db = DatabaseHelper.instance;
    await db.deleteAllAlerts();
    print('🟢 [ALERT] All alerts cleared');
  }

  // Check monitoring status
  bool isMonitoring() => _isMonitoring;
}
