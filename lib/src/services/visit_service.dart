import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_client.dart';

class VisitService {
  final SupabaseClient _client = SupabaseClientService().client;

  Future<Map<String, dynamic>> logVisit({
    required String leadId,
    String? notes,
    String? outcome,
    String visitType = 'knock',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Insert the visit
    final visit = await _client.from('visits').insert({
      'lead_id': leadId,
      'user_id': userId,
      'notes': notes,
      'outcome': outcome,
      'visit_type': visitType,
      'visited_at': DateTime.now().toIso8601String(),
    }).select().single();

    // Update lead visit count and last visited date
    await _client.from('leads').update({
      'visit_count': _client.rpc('increment_visit_count', params: {'lead_id': leadId}),
      'last_visited_at': DateTime.now().toIso8601String(),
    }).eq('id', leadId);

    return visit;
  }

  Future<List<Map<String, dynamic>>> getVisitsForLead(String leadId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('visits')
        .select()
        .eq('lead_id', leadId)
        .eq('user_id', userId)
        .order('visited_at', ascending: false);

    return response;
  }

  Future<Map<String, dynamic>> getVisitCounts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('leads')
        .select('visit_count')
        .eq('user_id', userId);

    int totalVisits = 0;
    for (var lead in response) {
      totalVisits += lead['visit_count'] ?? 0;
    }

    return {'total_visits': totalVisits};
  }

  Future<Map<String, dynamic>> getLatestVisitForLead(String leadId) async {
    final response = await _client
        .from('visits')
        .select()
        .eq('lead_id', leadId)
        .order('visited_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return response ?? {};
  }
}
