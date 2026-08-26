import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_client.dart';

class LeadService {
  final SupabaseClient _client = SupabaseClientService().client;

  // Create a new lead
  Future<Map<String, dynamic>> createLead({
    required String name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('leads')
        .insert({
          'user_id': userId,
          'name': name,
          'phone': phone,
          'email': email,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
          'status': 'new',
        })
        .select()
        .single();

    return response;
  }

  // Get all leads for the current user
  Future<List<Map<String, dynamic>>> getLeads() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from('leads')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response;
  }

  // Get a single lead by ID
  Future<Map<String, dynamic>> getLead(String leadId) async {
    final response = await _client
        .from('leads')
        .select()
        .eq('id', leadId)
        .single();

    return response;
  }

  // Update a lead
  Future<Map<String, dynamic>> updateLead({
    required String leadId,
    String? name,
    String? phone,
    String? email,
    String? address,
    double? latitude,
    double? longitude,
    String? status,
    String? notes,
  }) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (address != null) updates['address'] = address;
    if (latitude != null) updates['latitude'] = latitude;
    if (longitude != null) updates['longitude'] = longitude;
    if (status != null) updates['status'] = status;
    if (notes != null) updates['notes'] = notes;

    final response = await _client
        .from('leads')
        .update(updates)
        .eq('id', leadId)
        .select()
        .single();

    return response;
  }

  // Delete a lead
  Future<void> deleteLead(String leadId) async {
    await _client.from('leads').delete().eq('id', leadId);
  }

  // Log a visit for a lead
  Future<Map<String, dynamic>> logVisit({
    required String leadId,
    String? notes,
    String? outcome,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Insert visit
    final visit = await _client.from('visits').insert({
      'lead_id': leadId,
      'user_id': userId,
      'notes': notes,
      'outcome': outcome,
      'visited_at': DateTime.now().toIso8601String(),
    }).select().single();

    // Update lead visit count and last visited date
    await _client.from('leads').update({
      'visit_count': _client.rpc('increment_visit_count', params: {'lead_id': leadId}),
      'last_visited_at': DateTime.now().toIso8601String(),
    }).eq('id', leadId);

    return visit;
  }
}
