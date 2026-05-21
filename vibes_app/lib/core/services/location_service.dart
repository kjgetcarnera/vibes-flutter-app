// ignore_for_file: avoid_print
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({this.latitude, this.longitude, this.error});

  final double? latitude;
  final double? longitude;
  final String? error;

  bool get hasLocation => latitude != null && longitude != null;
}

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Requests permission if needed and returns the current position.
  /// Always resolves — never throws. On failure [LocationResult.error] is set.
  Future<LocationResult> fetchCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(error: 'Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(error: 'Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          error: 'Location permission permanently denied.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final result = LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      print('');
      print('━━━━━━━━━━━━ [LOCATION] ━━━━━━━━━━━━');
      print('[Location] Latitude       : ${position.latitude}');
      print('[Location] Longitude      : ${position.longitude}');
      print('[Location] Altitude       : ${position.altitude} m');
      print('[Location] Accuracy       : ${position.accuracy} m');
      print('[Location] Speed          : ${position.speed} m/s');
      print('[Location] Heading        : ${position.heading}°');
      print('[Location] Timestamp      : ${position.timestamp}');

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          print('[Location] ── Address ──────────────');
          print('[Location] Name           : ${p.name}');
          print('[Location] Street         : ${p.street}');
          print('[Location] Sub-locality   : ${p.subLocality}');
          print('[Location] Locality/City  : ${p.locality}');
          print('[Location] Sub-admin area : ${p.subAdministrativeArea}');
          print('[Location] Admin area     : ${p.administrativeArea}');
          print('[Location] Postal code    : ${p.postalCode}');
          print('[Location] Country        : ${p.country}');
          print('[Location] Country code   : ${p.isoCountryCode}');
        }
      } catch (e) {
        print('[Location] Reverse geocoding failed: $e');
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('');
      return result;
    } catch (e) {
      print('[Location] ERROR: $e');
      return LocationResult(error: e.toString());
    }
  }
}
