import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CrmProvider {
  apiNation,
  zapier,
}

class CrmSyncTarget {
  const CrmSyncTarget({
    required this.provider,
    required this.displayName,
    required this.autoSync,
    required this.webhookUrl,
    required this.apiKey,
  });

  final CrmProvider provider;
  final String displayName;
  final bool autoSync;
  final String webhookUrl;
  final String apiKey;

  CrmSyncTarget copyWith({
    CrmProvider? provider,
    String? displayName,
    bool? autoSync,
    String? webhookUrl,
    String? apiKey,
  }) {
    return CrmSyncTarget(
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      autoSync: autoSync ?? this.autoSync,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider.name,
      'displayName': displayName,
      'autoSync': autoSync,
      'webhookUrl': webhookUrl,
      'apiKey': apiKey,
    };
  }

  static CrmSyncTarget fromJson(Map<String, dynamic> json) {
    return CrmSyncTarget(
      provider: CrmProvider.values.firstWhere(
        (value) => value.name == json['provider'],
        orElse: () => CrmProvider.apiNation,
      ),
      displayName: json['displayName'] as String? ?? 'API Nation',
      autoSync: json['autoSync'] as bool? ?? false,
      webhookUrl: json['webhookUrl'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
    );
  }
}

class CrmSyncStore {
  CrmSyncStore._();

  static const _prefsKey = 'crm_sync_targets_v1';

  static final CrmSyncStore instance = CrmSyncStore._();

  final ValueNotifier<List<CrmSyncTarget>> targets =
      ValueNotifier<List<CrmSyncTarget>>(_defaultTargets);

  bool _isLoaded = false;

  static const List<CrmSyncTarget> _defaultTargets = <CrmSyncTarget>[
    CrmSyncTarget(
      provider: CrmProvider.apiNation,
      displayName: 'API Nation',
      autoSync: false,
      webhookUrl: '',
      apiKey: '',
    ),
    CrmSyncTarget(
      provider: CrmProvider.zapier,
      displayName: 'Zapier',
      autoSync: false,
      webhookUrl: '',
      apiKey: '',
    ),
  ];

  Future<void> ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _isLoaded = true;
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final loaded = decoded
          .map((item) => CrmSyncTarget.fromJson(item as Map<String, dynamic>))
          .toList();

      final byProvider = <CrmProvider, CrmSyncTarget>{
        for (final target in loaded) target.provider: target,
      };
      final merged = _defaultTargets
          .map((target) => byProvider[target.provider] ?? target)
          .toList();
      targets.value = merged;
    } catch (_) {
      targets.value = _defaultTargets;
    }

    _isLoaded = true;
  }

  Future<void> saveTargets(List<CrmSyncTarget> nextTargets) async {
    targets.value = nextTargets;
    _isLoaded = true;

    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(nextTargets.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, payload);
  }

  CrmSyncTarget? findTarget(CrmProvider provider) {
    for (final target in targets.value) {
      if (target.provider == provider) {
        return target;
      }
    }
    return null;
  }
}
