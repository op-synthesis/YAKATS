import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String weatherCondition;
  final int weatherCode;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCondition,
    required this.weatherCode,
  });
}

class WeatherService {
  // Open-Meteo API endpoint (no API key needed!)
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<WeatherData?> getWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      print('🔵 [WEATHER] Fetching weather for: $latitude, $longitude');

      // Build the URL with parameters
      final url = Uri.parse(
        '$baseUrl?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&temperature_unit=celsius',
      );

      print('🔵 [WEATHER] URL: $url');

      // Make the request
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      print('🔵 [WEATHER] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final current = json['current'];

        final weatherData = WeatherData(
          temperature: (current['temperature_2m'] as num).toDouble(),
          humidity: (current['relative_humidity_2m'] as int).toDouble(),
          windSpeed: (current['wind_speed_10m'] as num).toDouble(),
          weatherCode: current['weather_code'] as int,
          weatherCondition: _getWeatherDescription(
            current['weather_code'] as int,
          ),
        );

        print(
          '🟢 [WEATHER] Got weather: ${weatherData.temperature}°C, ${weatherData.weatherCondition}',
        );
        return weatherData;
      } else {
        print('🔴 [WEATHER] API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔴 [WEATHER] Error: $e');
      return null;
    }
  }

  // Convert WMO weather codes to descriptions (Turkish)
  static String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Açık Hava'; // Clear sky
      case 1 || 2:
        return 'Az Bulutlu'; // Mainly clear, partly cloudy
      case 3:
        return 'Bulutlu'; // Overcast
      case 45 || 48:
        return 'Sisli'; // Foggy
      case 51 || 53 || 55:
        return 'Hafif Yağmur'; // Drizzle
      case 61 || 63 || 65:
        return 'Yağmur'; // Rain
      case 71 || 73 || 75:
        return 'Kar'; // Snow
      case 80 || 81 || 82:
        return 'Sağanak Yağmur'; // Rain showers
      case 85 || 86:
        return 'Kar Sağanağı'; // Snow showers
      case 95 || 96 || 99:
        return 'Gök Gürültülü Fırtına'; // Thunderstorm
      default:
        return 'Bilinmiyor'; // Unknown
    }
  }
}
