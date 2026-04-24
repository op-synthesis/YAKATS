import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      print('🔵 [LOCATION] Requesting location...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('🟠 [LOCATION] Location services disabled');
        await Geolocator.openLocationSettings();
        return null;
      }

      print('🔵 [LOCATION] Getting position...');

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        '🟢 [LOCATION] Got position: ${position.latitude}, ${position.longitude}',
      );

      // Get address from coordinates
      String locationName = await _getLocationName(
        position.latitude,
        position.longitude,
      );

      print('🟢 [LOCATION] Location: $locationName');

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'locationName': locationName,
      };
    } catch (e) {
      print('🔴 [LOCATION] Error: $e');
      return null;
    }
  }

  static Future<String> _getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        List<String> parts = [];
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          parts.add(place.administrativeArea!);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      print('🔴 [LOCATION] Error getting name: $e');
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }
}
