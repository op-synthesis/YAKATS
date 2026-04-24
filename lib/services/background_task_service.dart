import 'background_service.dart';

class BackgroundTaskService {
  static final BackgroundTaskService _instance =
      BackgroundTaskService._internal();

  factory BackgroundTaskService() {
    return _instance;
  }

  BackgroundTaskService._internal();

  static bool _isInitialized = false;

  // Initialize background tasks
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔵 [BACKGROUND TASKS] Initializing...');

    try {
      await BackgroundService.initialize();
      _isInitialized = true;
      print('🟢 [BACKGROUND TASKS] Initialized successfully');
    } catch (e) {
      print('🔴 [BACKGROUND TASKS] Initialization error: $e');
    }
  }

  // Start periodic risk checks (background)
  static Future<void> startPeriodicRiskCheck() async {
    print('🔵 [BACKGROUND TASKS] Starting periodic risk checks...');

    try {
      await BackgroundService.startService();
      print('🟢 [BACKGROUND TASKS] Periodic risk checks started');
      print('✅ BACKGROUND NOTIFICATIONS ENABLED!');
    } catch (e) {
      print('🔴 [BACKGROUND TASKS] Error: $e');
    }
  }

  // Stop periodic risk checks
  static Future<void> stopPeriodicRiskCheck() async {
    print('🔵 [BACKGROUND TASKS] Stopping periodic risk checks...');

    try {
      await BackgroundService.stopService();
      print('🟢 [BACKGROUND TASKS] Periodic risk checks stopped');
    } catch (e) {
      print('🔴 [BACKGROUND TASKS] Error: $e');
    }
  }

  // Check if background service is running
  static Future<bool> isRunning() async {
    return await BackgroundService.isServiceRunning();
  }

  static Future<void> cancelAll() async {
    await stopPeriodicRiskCheck();
    print('🟢 [BACKGROUND TASKS] All tasks canceled');
  }
}
