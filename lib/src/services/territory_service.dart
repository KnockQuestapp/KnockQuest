import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../config/supabase_client.dart';

class TerritoryService {
  final SupabaseClient _client = SupabaseClientService().client;

  Future<Map<String, dynamic>> createTerritory({
    required String name,
    String? description,
    required List<LatLng> polygon,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Convert polygon to GeoJSON or WKT format for PostGIS
    final polygonWKT = _polygonToWKT(polygon);

    final response = await _client
        .from('territories')
        .insert({
          'user_id': userId,
          'name': name,
          'description': description,
          'polygon': polygonWKT,
        })
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getTerritories() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('territories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response;
  }

  Future<void> deleteTerritory(String territoryId) async {
    await _client.from('territories').delete().eq('id', territoryId);
  }

  String _polygonToWKT(List<LatLng> polygon) {
    if (polygon.length < 3) {
      throw Exception('Polygon must have at least 3 points');
    }

    // Close the polygon if not already closed
    final points = List<LatLng>.from(polygon);
    if (points.first != points.last) {
      points.add(points.first);
    }

    final coords = points.map((p) => '${p.longitude} ${p.latitude}').join(',');
    return 'POLYGON(($coords))';
  }

  // Check if a point is inside any territory
  Future<bool> isPointInTerritory(LatLng point) async {
    // Use PostGIS ST_Contains function
    final result = await _client.rpc('is_point_in_territory', params: {
      'lat': point.latitude,
      'lng': point.longitude,
      'user_id': _client.auth.currentUser?.id,
    });
    return result as bool? ?? false;
  }
}
