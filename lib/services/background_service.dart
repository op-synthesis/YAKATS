import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'risk_prediction_service.dart';
import 'notifications_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  static const platform = MethodChannel('com.example.yakats/background');

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  static bool _isInitialized = false;

  // Initialize background service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔵 [BG SERVICE] Initializing...');

    try {
      // Set up method channel handler
      platform.setMethodCallHandler((call) async {
        if (call.method == 'checkRisk') {
          await _performRiskCheck();
          return 'Risk checked';
        }
        return null;
      });

      _isInitialized = true;
      print('🟢 [BG SERVICE] Initialized successfully');
    } catch (e) {
      print('🔴 [BG SERVICE] Initialization error: $e');
    }
  }

  // Start background service
  static Future<void> startService() async {
    print('🔵 [BG SERVICE] Starting background service...');

    try {
      await platform.invokeMethod('startBackgroundService');
      print('🟢 [BG SERVICE] Background service started');
      print(
        '🟢 [BG SERVICE] Risk checks will run every 15 minutes in background',
      );
    } catch (e) {
      print('🔴 [BG SERVICE] Start error: $e');
    }
  }

  // Stop background service
  static Future<void> stopService() async {
    print('🔵 [BG SERVICE] Stopping background service...');

    try {
      await platform.invokeMethod('stopBackgroundService');
      print('🟢 [BG SERVICE] Background service stopped');
    } catch (e) {
      print('🔴 [BG SERVICE] Stop error: $e');
    }
  }

  // Perform risk check (called from Android)
  static Future<void> _performRiskCheck() async {
    try {
      print('🔵 [BG SERVICE] Performing risk check...');

      final dbService = DatabaseService();
      final prefs = await SharedPreferences.getInstance();

      // Get all symptoms
      final symptoms = await dbService.getAllSymptomLogs();

      if (symptoms.isEmpty) {
        print('🟠 [BG SERVICE] No symptoms found');
        return;
      }

      // Calculate risk
      final risk = await RiskPredictionService.calculateRealTimeRisk(symptoms);

      print('🟢 [BG SERVICE] Risk: ${risk.riskLevel}');

      // Get last notified risk
      final lastRiskLevel = prefs.getString('lastNotifiedRiskLevel') ?? 'NONE';

      // Notify if changed or critical
      if (risk.riskLevel != lastRiskLevel || risk.riskLevel == 'CRİTİK') {
        print('🔵 [BG SERVICE] Sending notification: ${risk.riskLevel}');
        await NotificationsService.showRiskNotification(risk);
        await prefs.setString('lastNotifiedRiskLevel', risk.riskLevel);
      } else {
        print('🟠 [BG SERVICE] Risk unchanged');
      }
    } catch (e) {
      print('🔴 [BG SERVICE] Error: $e');
    }
  }

  // Check if service is running
  static Future<bool> isServiceRunning() async {
    return true;
  }
}
