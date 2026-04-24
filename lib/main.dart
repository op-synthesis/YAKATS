import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/log_symptom_screen.dart';
import 'screens/history_screen.dart';
import 'screens/risk_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/alerts_screen.dart';
import 'utils/app_theme.dart';
import 'services/alert_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('tr', null);
  } catch (e) {
    print('🔴 [MAIN] Date formatting error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkTheme') ?? false;

  try {
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
  } catch (e) {
    print('🔴 [MAIN] Notification error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AlertService>(
          create: (_) => AlertService()..initialize(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider(isDark: isDark)),
      ],
      child: const YakatsApp(),
    ),
  );
}

// ─── Theme Provider ────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  ThemeProvider({required bool isDark}) : _isDark = isDark;

  bool get isDark => _isDark;

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDark);
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDark);
  }
}

// ─── App ───────────────────────────────────────────────────────
class YakatsApp extends StatelessWidget {
  const YakatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final GoRouter router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/log-symptom',
          builder: (context, state) => const LogSymptomScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/insights',
          builder: (context, state) => const InsightsScreen(),
        ),
        GoRoute(
          path: '/risk-details',
          builder: (context, state) => const RiskDetailsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      title: 'YAKATS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
