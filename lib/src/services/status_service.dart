import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_client.dart';

class StatusService {
  final SupabaseClient _client = SupabaseClientService().client;

  // Lead status types
  static const List<String> statuses = [
    'Prospect',
    'Active',
    'Follow-up',
    'Under Contract',
    'Closed',
    'Do Not Solicit',
  ];

  static const Map<String, int> statusOrder = {
    'Prospect': 0,
    'Active': 1,
    'Follow-up': 2,
    'Under Contract': 3,
    'Closed': 4,
    'Do Not Solicit': 5,
  };

  static const Map<String, String> statusColors = {
    'Prospect': '#3498db',
    'Active': '#2ecc71',
    'Follow-up': '#f39c12',
    'Under Contract': '#9b59b6',
    'Closed': '#27ae60',
    'Do Not Solicit': '#e74c3c',
  };

  Future<Map<String, dynamic>> updateLeadStatus({
    required String leadId,
    required String newStatus,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    if (!statuses.contains(newStatus)) {
      throw Exception('Invalid status: $newStatus');
    }

    // Update the lead status
    final updatedLead = await _client
        .from('leads')
        .update({
          'status': newStatus.toLowerCase().replaceAll(' ', '-'),
          'notes': notes,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', leadId)
        .select()
        .single();

    // Create status history entry
    await _createStatusHistory(leadId, newStatus, userId, notes);

    return updatedLead;
  }

  Future<void> _createStatusHistory(
    String leadId,
    String status,
    String userId,
    String? notes,
  ) async {
    // Create a history table entry
    await _client.from('status_history').insert({
      'lead_id': leadId,
      'user_id': userId,
      'status': status.toLowerCase().replaceAll(' ', '-'),
      'notes': notes,
      'changed_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getStatusHistory(String leadId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('status_history')
        .select()
        .eq('lead_id', leadId)
        .eq('user_id', userId)
        .order('changed_at', ascending: false);

    return response;
  }

  Future<Map<String, int>> getStatusCounts() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('leads')
        .select('status')
        .eq('user_id', userId);

    final counts = <String, int>{};
    for (var lead in response) {
      final status = lead['status'] as String? ?? 'new';
      final displayStatus = _formatStatus(status);
      counts[displayStatus] = (counts[displayStatus] ?? 0) + 1;
    }

    return counts;
  }

  String _formatStatus(String status) {
    final map = {
      'new': 'Prospect',
      'contacted': 'Active',
      'follow-up': 'Follow-up',
      'under-contract': 'Under Contract',
      'closed': 'Closed',
      'dns': 'Do Not Solicit',
    };
    return map[status] ?? status;
  }
}
