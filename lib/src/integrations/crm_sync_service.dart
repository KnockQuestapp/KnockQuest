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

    final result = await _postLeadEvent(
      target: target,
      event: 'integration.test',
      lead: sampleLead,
    );
    await CrmSyncStore.instance.markSyncResult(
      provider: provider,
      success: result.success,
      message: result.message,
    );
    await CrmSyncStore.instance.appendActivity(
      provider: provider,
      event: 'integration.test',
      success: result.success,
      message: result.message,
      leadName: sampleLead.name,
    );
    return result.message;
  }

  Future<String> retryFailedSyncs(CrmProvider provider) async {
    await CrmSyncStore.instance.ensureLoaded();
    final target = CrmSyncStore.instance.findTarget(provider);
    if (target == null) {
      return 'Integration not found.';
    }

    final queued = CrmSyncStore.instance.retriesFor(provider);
    if (queued.isEmpty) {
      return 'No failed syncs to retry.';
    }

    if (target.webhookUrl.trim().isEmpty) {
      return 'Configure a webhook URL before retrying failed syncs.';
    }

    var succeeded = 0;
    var failed = 0;

    for (final item in queued) {
      try {
        final result = await _postEventPayload(
          target: target,
          payload: item.payload,
        );
        if (result.success) {
          succeeded += 1;
          await CrmSyncStore.instance.removeRetryById(item.id);
          await CrmSyncStore.instance.appendActivity(
            provider: provider,
            event: item.payload['event'] as String? ?? 'retry.unknown',
            success: true,
            message: 'Retry delivered (${item.attempts + 1} attempts).',
            leadName: _leadNameFromPayload(item.payload),
          );
        } else {
          failed += 1;
          await CrmSyncStore.instance.replaceRetry(
            item.copyWith(
              attempts: item.attempts + 1,
              lastError: result.message,
            ),
          );
          await CrmSyncStore.instance.appendActivity(
            provider: provider,
            event: item.payload['event'] as String? ?? 'retry.unknown',
            success: false,
            message: result.message,
            leadName: _leadNameFromPayload(item.payload),
          );
        }
      } catch (error) {
        failed += 1;
        await CrmSyncStore.instance.replaceRetry(
          item.copyWith(
            attempts: item.attempts + 1,
            lastError: error.toString(),
          ),
        );
        await CrmSyncStore.instance.appendActivity(
          provider: provider,
          event: item.payload['event'] as String? ?? 'retry.unknown',
          success: false,
          message: 'Retry exception: $error',
          leadName: _leadNameFromPayload(item.payload),
        );
      }
    }

    final summary = failed == 0
        ? 'Retry complete. $succeeded event(s) delivered.'
        : 'Retry complete. $succeeded succeeded, $failed still pending.';

    await CrmSyncStore.instance.markSyncResult(
      provider: provider,
      success: failed == 0,
      message: summary,
    );

    return summary;
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
        final payload = _buildLeadPayload(event: event, lead: lead, target: target);
        final result = await _postEventPayload(
          target: target,
          payload: payload,
        );
        if (result.success) {
          await CrmSyncStore.instance.markSyncResult(
            provider: target.provider,
            success: true,
            message: result.message,
          );
          await CrmSyncStore.instance.appendActivity(
            provider: target.provider,
            event: event,
            success: true,
            message: result.message,
            leadName: lead.name,
          );
        } else {
          await CrmSyncStore.instance.enqueueRetry(
            provider: target.provider,
            payload: payload,
            lastError: result.message,
          );
          await CrmSyncStore.instance.markSyncResult(
            provider: target.provider,
            success: false,
            message: '${result.message} Added to retry queue.',
          );
          await CrmSyncStore.instance.appendActivity(
            provider: target.provider,
            event: event,
            success: false,
            message: result.message,
            leadName: lead.name,
          );
        }
      } catch (error) {
        final payload = _buildLeadPayload(event: event, lead: lead, target: target);
        await CrmSyncStore.instance.enqueueRetry(
          provider: target.provider,
          payload: payload,
          lastError: error.toString(),
        );
        await CrmSyncStore.instance.markSyncResult(
          provider: target.provider,
          success: false,
          message: 'Sync exception: $error',
        );
        await CrmSyncStore.instance.appendActivity(
          provider: target.provider,
          event: event,
          success: false,
          message: 'Sync exception: $error',
          leadName: lead.name,
        );
        debugPrint('CRM sync failed for ${target.displayName}: $error');
      }
    }
  }

  String _leadNameFromPayload(Map<String, dynamic> payload) {
    final lead = payload['lead'];
    if (lead is Map && lead['name'] is String) {
      return lead['name'] as String;
    }
    return 'Lead';
  }

  Map<String, dynamic> _buildLeadPayload({
    required String event,
    required LeadRecord lead,
    required CrmSyncTarget target,
  }) {
    final leadData = <String, dynamic>{
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
    };

    final mappedLead = <String, dynamic>{};
    for (final entry in target.fieldMappings.entries) {
      final sourceKey = entry.key;
      final destinationKey = entry.value.trim();
      if (destinationKey.isEmpty || !leadData.containsKey(sourceKey)) {
        continue;
      }
      mappedLead[destinationKey] = leadData[sourceKey];
    }

    return <String, dynamic>{
      'event': event,
      'provider': target.provider.name,
      'occurredAt': DateTime.now().toIso8601String(),
      'lead': leadData,
      'mappedLead': mappedLead,
    };
  }

  Future<_SyncPostResult> _postLeadEvent({
    required CrmSyncTarget target,
    required String event,
    required LeadRecord lead,
  }) async {
    final payload = _buildLeadPayload(event: event, lead: lead, target: target);
    return _postEventPayload(target: target, payload: payload);
  }

  Future<_SyncPostResult> _postEventPayload({
    required CrmSyncTarget target,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.tryParse(target.webhookUrl.trim());
    if (uri == null || !uri.hasScheme) {
      return const _SyncPostResult(false, 'Invalid webhook URL.');
    }

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
      return _SyncPostResult(true, 'Connected (${response.statusCode})');
    }

    return _SyncPostResult(
      false,
      'Sync failed (${response.statusCode}): ${response.body}',
    );
  }
}

class _SyncPostResult {
  const _SyncPostResult(this.success, this.message);

  final bool success;
  final String message;
}
