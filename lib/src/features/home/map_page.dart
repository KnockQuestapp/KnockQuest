import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../config/app_config.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static final LatLng _defaultCenter = LatLng(40.7128, -74.0060);

  @override
  Widget build(BuildContext context) {
    if (AppConfig.mapProvider == MapProvider.google) {
      return _GoogleMapsPlannedView(apiKeyConfigured: AppConfig.googleMapsApiKey.isNotEmpty);
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.knockquest.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _defaultCenter,
              width: 40,
              height: 40,
              child: const Icon(Icons.place, color: Colors.red, size: 36),
            ),
          ],
        ),
      ],
    );
  }
}

class _GoogleMapsPlannedView extends StatelessWidget {
  const _GoogleMapsPlannedView({required this.apiKeyConfigured});

  final bool apiKeyConfigured;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 48),
            const SizedBox(height: 12),
            Text(
              'Google Maps mode is configured but not enabled in this baseline.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              apiKeyConfigured
                  ? 'API key detected via GOOGLE_MAPS_API_KEY.'
                  : 'No GOOGLE_MAPS_API_KEY detected.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
