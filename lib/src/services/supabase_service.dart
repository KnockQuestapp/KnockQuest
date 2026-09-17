import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import '../sample_data.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;
  late final SupabaseClient _client;

  Future<void> init() async {
    if (_initialized) return;

    if (!SupabaseConfig.isConfigured) {
      // We use a dummy client or just skip initialization if not configured.
      // For the purpose of this MVP, we'll proceed but operations will fail.
      debugPrint('Supabase not configured. Please update supabase_config.dart');
    }

    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );

    _client = Supabase.instance.client;
    _initialized = true;
  }

  // --- Authentication ---

  Future<AuthResponse> signUp(
    String email,
    String password, {
    String? name,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'full_name': name} : null,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // --- Leads Sync ---

  Future<void> syncLeads(List<LeadRecord> localLeads) async {
    if (!SupabaseConfig.isConfigured) return;

    try {
      // Convert local leads to maps for Supabase
      final leadsData = localLeads.map((l) => l.toMap()).toList();

      // Upsert leads into the 'leads' table
      await _client.from('leads').upsert(leadsData);
    } catch (e) {
      debugPrint('Error syncing leads to Supabase: $e');
    }
  }

  Future<List<LeadRecord>> fetchLeads() async {
    if (!SupabaseConfig.isConfigured) return [];

    try {
      final data = await _client.from('leads').select();
      return (data as List).map((map) => LeadRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error fetching leads from Supabase: $e');
      return [];
    }
  }

  // --- Global Metrics ---

  Future<Map<String, dynamic>> fetchGlobalMetrics() async {
    if (!SupabaseConfig.isConfigured) {
      return {'total_gci': 0.0, 'total_leads': 0, 'conversion_rate': 0.0};
    }

    try {
      // In a real Supabase setup, these would be computed via RPC or views
      final leadsData = await _client.from('leads').select();
      final leads = leadsData as List;

      double totalGci = 0;
      int closedLeads = 0;

      for (var lead in leads) {
        totalGci += (lead['estimated_value'] ?? 0).toDouble();
        if (lead['status'] == 'Closed') {
          closedLeads++;
        }
      }

      return {
        'total_gci': totalGci,
        'total_leads': leads.length,
        'conversion_rate': leads.isEmpty
            ? 0.0
            : (closedLeads / leads.length) * 100,
      };
    } catch (e) {
      debugPrint('Error fetching global metrics: $e');
      return {};
    }
  }
}
