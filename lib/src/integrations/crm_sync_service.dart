import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../sample_data.dart';
import 'crm_sync_store.dart';

class CrmSyncService {
  CrmSyncService._();

  static final CrmSyncService instance = CrmSyncService._();

  Future<void> syncLeadCreated(LeadRecord lead) async {
    await _syncLeadEvent(event: 'lead.created', lead: lead);
  }

  Future<void> syncLeadUpdated(LeadRecord lead) async {
    await _syncLeadEvent(event: 'lead.updated', lead: lead);
  }

  Future<String> sendTestEvent(CrmProvider provider) async {
    await CrmSyncStore.instance.ensureLoaded();
    final target = CrmSyncStore.instance.findTarget(provider);
    if (target == null) {
      return 'Integration not found.';
    }

    if (target.webhookUrl.trim().isEmpty) {
      return 'Webhook URL is required before running a test.';
    }

    return _postLeadEvent(
      target: target,
      event: 'integration.test',
      lead: sampleLead,
    );
  }

  Future<void> _syncLeadEvent({
    required String event,
    required LeadRecord lead,
  }) async {
    await CrmSyncStore.instance.ensureLoaded();

    final activeTargets = CrmSyncStore.instance.targets.value.where((target) {
      return target.autoSync && target.webhookUrl.trim().isNotEmpty;
    });

    for (final target in activeTargets) {
      try {
        await _postLeadEvent(target: target, event: event, lead: lead);
      } catch (error) {
        debugPrint('CRM sync failed for ${target.displayName}: $error');
      }
    }
  }

  Future<String> _postLeadEvent({
    required CrmSyncTarget target,
    required String event,
    required LeadRecord lead,
  }) async {
    final uri = Uri.tryParse(target.webhookUrl.trim());
    if (uri == null || !uri.hasScheme) {
      return 'Invalid webhook URL.';
    }

    final payload = <String, dynamic>{
      'event': event,
      'provider': target.provider.name,
      'occurredAt': DateTime.now().toIso8601String(),
      'lead': <String, dynamic>{
        'name': lead.name,
        'firstName': lead.firstName,
        'lastName': lead.lastName,
        'phone': lead.phone,
        'email': lead.email,
        'address': lead.address,
        'unitNumber': lead.unitNumber,
        'city': lead.city,
        'postalCode': lead.postalCode,
        'notes': lead.notes,
        'latitude': lead.latitude,
        'longitude': lead.longitude,
        'status': lead.status,
        'outcome': lead.outcome,
        'estimatedValue': lead.estimatedValue,
        'lastContactDate': lead.lastContactDate.toIso8601String(),
        'followUpDate': lead.followUpDate.toIso8601String(),
      },
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-KnockQuest-Source': 'knockquest-app',
    };
    if (target.apiKey.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${target.apiKey.trim()}';
    }

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return 'Connected (${response.statusCode})';
    }

    return 'Sync failed (${response.statusCode}): ${response.body}';
  }
}
