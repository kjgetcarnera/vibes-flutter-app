import 'package:flutter/material.dart';
import '../services/location_service.dart';

/// Drop this widget anywhere in the tree. It silently fetches the device
/// location on [initState] and exposes the result via [onResult].
/// Shows nothing — purely logic-carrying.
class LocationFetcher extends StatefulWidget {
  const LocationFetcher({super.key, required this.onResult});

  final void Function(LocationResult result) onResult;

  @override
  State<LocationFetcher> createState() => _LocationFetcherState();
}

class _LocationFetcherState extends State<LocationFetcher> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final result = await LocationService.instance.fetchCurrentLocation();
    if (mounted) widget.onResult(result);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
