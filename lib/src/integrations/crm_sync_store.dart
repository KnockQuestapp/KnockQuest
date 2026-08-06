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
    this.lastStatus = 'idle',
    this.lastMessage = '',
    this.lastAttemptAt,
    this.lastSuccessAt,
  });

  final CrmProvider provider;
  final String displayName;
  final bool autoSync;
  final String webhookUrl;
  final String apiKey;
  final String lastStatus;
  final String lastMessage;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;

  CrmSyncTarget copyWith({
    CrmProvider? provider,
    String? displayName,
    bool? autoSync,
    String? webhookUrl,
    String? apiKey,
    String? lastStatus,
    String? lastMessage,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
  }) {
    return CrmSyncTarget(
      provider: provider ?? this.provider,
      displayName: displayName ?? this.displayName,
      autoSync: autoSync ?? this.autoSync,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      apiKey: apiKey ?? this.apiKey,
      lastStatus: lastStatus ?? this.lastStatus,
      lastMessage: lastMessage ?? this.lastMessage,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider.name,
      'displayName': displayName,
      'autoSync': autoSync,
      'webhookUrl': webhookUrl,
      'apiKey': apiKey,
      'lastStatus': lastStatus,
      'lastMessage': lastMessage,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'lastSuccessAt': lastSuccessAt?.toIso8601String(),
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
      lastStatus: json['lastStatus'] as String? ?? 'idle',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.tryParse(json['lastAttemptAt'] as String),
      lastSuccessAt: json['lastSuccessAt'] == null
          ? null
          : DateTime.tryParse(json['lastSuccessAt'] as String),
    );
  }
}

class CrmSyncRetryItem {
  const CrmSyncRetryItem({
    required this.id,
    required this.provider,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    required this.lastError,
  });

  final String id;
  final CrmProvider provider;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String lastError;

  CrmSyncRetryItem copyWith({
    String? id,
    CrmProvider? provider,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? attempts,
    String? lastError,
  }) {
    return CrmSyncRetryItem(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'provider': provider.name,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'lastError': lastError,
    };
  }

  static CrmSyncRetryItem fromJson(Map<String, dynamic> json) {
    return CrmSyncRetryItem(
      id: json['id'] as String,
      provider: CrmProvider.values.firstWhere(
        (value) => value.name == json['provider'],
        orElse: () => CrmProvider.apiNation,
      ),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : <String, dynamic>{},
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      attempts: json['attempts'] as int? ?? 1,
      lastError: json['lastError'] as String? ?? '',
    );
  }
}

class CrmSyncStore {
  CrmSyncStore._();

  static const _prefsKey = 'crm_sync_targets_v1';
  static const _retryPrefsKey = 'crm_sync_retry_items_v1';

  static final CrmSyncStore instance = CrmSyncStore._();

  final ValueNotifier<List<CrmSyncTarget>> targets =
      ValueNotifier<List<CrmSyncTarget>>(_defaultTargets);
    final ValueNotifier<List<CrmSyncRetryItem>> retryQueue =
      ValueNotifier<List<CrmSyncRetryItem>>(<CrmSyncRetryItem>[]);

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

    final rawRetry = prefs.getString(_retryPrefsKey);
    if (rawRetry != null && rawRetry.isNotEmpty) {
      try {
        final decodedRetry = jsonDecode(rawRetry) as List<dynamic>;
        retryQueue.value = decodedRetry
            .map((item) =>
                CrmSyncRetryItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        retryQueue.value = <CrmSyncRetryItem>[];
      }
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

  Future<void> _saveRetryQueue(List<CrmSyncRetryItem> items) async {
    retryQueue.value = items;
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_retryPrefsKey, payload);
  }

  Future<void> updateTarget(
    CrmProvider provider,
    CrmSyncTarget Function(CrmSyncTarget current) update,
  ) async {
    await ensureLoaded();
    final next = <CrmSyncTarget>[];
    for (final target in targets.value) {
      if (target.provider == provider) {
        next.add(update(target));
      } else {
        next.add(target);
      }
    }
    await saveTargets(next);
  }

  Future<void> markSyncResult({
    required CrmProvider provider,
    required bool success,
    required String message,
  }) async {
    await updateTarget(provider, (current) {
      return current.copyWith(
        lastStatus: success ? 'success' : 'failed',
        lastMessage: message,
        lastAttemptAt: DateTime.now(),
        lastSuccessAt: success ? DateTime.now() : current.lastSuccessAt,
      );
    });
  }

  Future<void> enqueueRetry({
    required CrmProvider provider,
    required Map<String, dynamic> payload,
    required String lastError,
  }) async {
    await ensureLoaded();
    final item = CrmSyncRetryItem(
      id: '${provider.name}-${DateTime.now().microsecondsSinceEpoch}',
      provider: provider,
      payload: payload,
      createdAt: DateTime.now(),
      attempts: 1,
      lastError: lastError,
    );

    await _saveRetryQueue([...retryQueue.value, item]);
  }

  Future<void> replaceRetry(CrmSyncRetryItem nextItem) async {
    await ensureLoaded();
    final next = retryQueue.value.map((item) {
      if (item.id == nextItem.id) {
        return nextItem;
      }
      return item;
    }).toList();
    await _saveRetryQueue(next);
  }

  Future<void> removeRetryById(String retryId) async {
    await ensureLoaded();
    final next = retryQueue.value.where((item) => item.id != retryId).toList();
    await _saveRetryQueue(next);
  }

  List<CrmSyncRetryItem> retriesFor(CrmProvider provider) {
    return retryQueue.value
        .where((item) => item.provider == provider)
        .toList();
  }

  int pendingCountFor(CrmProvider provider) {
    return retryQueue.value.where((item) => item.provider == provider).length;
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
