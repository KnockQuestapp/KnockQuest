import 'package:flutter/material.dart';

import '../../integrations/crm_sync_service.dart';
import '../../integrations/crm_sync_store.dart';

class _FieldMappingMeta {
  const _FieldMappingMeta({required this.key, required this.label});

  final String key;
  final String label;
}

const List<_FieldMappingMeta> _fieldMappings = <_FieldMappingMeta>[
  _FieldMappingMeta(key: 'firstName', label: 'First Name'),
  _FieldMappingMeta(key: 'lastName', label: 'Last Name'),
  _FieldMappingMeta(key: 'phone', label: 'Phone'),
  _FieldMappingMeta(key: 'email', label: 'Email'),
  _FieldMappingMeta(key: 'address', label: 'Address'),
];

class CrmIntegrationsPage extends StatefulWidget {
  const CrmIntegrationsPage({super.key});

  @override
  State<CrmIntegrationsPage> createState() => _CrmIntegrationsPageState();
}

class _CrmIntegrationsPageState extends State<CrmIntegrationsPage> {
  final Set<CrmProvider> _testingProviders = <CrmProvider>{};
  final Set<CrmProvider> _retryingProviders = <CrmProvider>{};
  List<_IntegrationDraft> _drafts = <_IntegrationDraft>[];

  @override
  void initState() {
    super.initState();
    _hydrateDraftsFromStore();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.webhookController.dispose();
      draft.apiKeyController.dispose();
      for (final controller in draft.mappingControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      await CrmSyncStore.instance.ensureLoaded();
    } catch (error) {
      debugPrint('CRM settings load fallback: $error');
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _hydrateDraftsFromStore();
    });
  }

  void _hydrateDraftsFromStore() {
    for (final draft in _drafts) {
      draft.webhookController.dispose();
      draft.apiKeyController.dispose();
      for (final controller in draft.mappingControllers.values) {
        controller.dispose();
      }
    }
    _drafts = CrmSyncStore.instance.targets.value
        .map((target) => _IntegrationDraft.fromTarget(target))
        .toList();
  }

  void _toggleSync(int index, bool value) {
    setState(() {
      _drafts[index] = _drafts[index].copyWith(autoSync: value);
    });
  }

  Future<void> _configure(int index, {bool showFeedback = true}) async {
    final draft = _drafts[index];
    final target = draft.toTarget();
    final nextTargets = [...CrmSyncStore.instance.targets.value];
    final targetIndex = nextTargets.indexWhere(
      (item) => item.provider == target.provider,
    );
    if (targetIndex >= 0) {
      nextTargets[targetIndex] = target;
    }

    await CrmSyncStore.instance.saveTargets(nextTargets);
    _hydrateDraftsFromStore();
    if (!mounted) {
      return;
    }

    setState(() {});

    if (showFeedback) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${target.displayName} configuration saved.')),
      );
    }
  }

  Future<void> _testConnection(int index) async {
    final provider = _drafts[index].provider;
    await _configure(index, showFeedback: false);
    if (!mounted) {
      return;
    }

    setState(() {
      _testingProviders.add(provider);
    });

    final result = await CrmSyncService.instance.sendTestEvent(provider);

    if (!mounted) {
      return;
    }
    setState(() {
      _testingProviders.remove(provider);
      _hydrateDraftsFromStore();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  Future<void> _retryFailed(int index) async {
    final provider = _drafts[index].provider;
    await _configure(index, showFeedback: false);
    if (!mounted) {
      return;
    }

    setState(() {
      _retryingProviders.add(provider);
    });

    final result = await CrmSyncService.instance.retryFailedSyncs(provider);

    if (!mounted) {
      return;
    }
    setState(() {
      _retryingProviders.remove(provider);
      _hydrateDraftsFromStore();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CRM & Integrations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                  const SizedBox(height: 6),
                  const Text('Sync leads to API Nation or Zapier via secure webhooks.', style: TextStyle(color: Color(0xFF8B99AB))),
                  const SizedBox(height: 24),
                  const Text('Connected Services', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var index = 0; index < _drafts.length; index++) ...[
                            _CrmCard(
                              name: _drafts[index].displayName,
                              accent: _drafts[index].accent,
                              autoSync: _drafts[index].autoSync,
                              lastStatus: _drafts[index].lastStatus,
                              lastMessage: _drafts[index].lastMessage,
                              lastAttemptAt: _drafts[index].lastAttemptAt,
                              lastSuccessAt: _drafts[index].lastSuccessAt,
                              pendingCount: CrmSyncStore.instance
                                  .pendingCountFor(_drafts[index].provider),
                              webhookController: _drafts[index].webhookController,
                              apiKeyController: _drafts[index].apiKeyController,
                                mappingControllers: _drafts[index].mappingControllers,
                              isTesting: _testingProviders.contains(_drafts[index].provider),
                              isRetrying: _retryingProviders.contains(_drafts[index].provider),
                              onConfigure: () => _configure(index),
                              onTestConnection: () => _testConnection(index),
                              onRetryFailed: () => _retryFailed(index),
                              onAutoSyncChanged: (value) => _toggleSync(index, value),
                            ),
                            if (index < _drafts.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrmCard extends StatelessWidget {
  const _CrmCard({
    required this.name,
    required this.accent,
    required this.autoSync,
    required this.lastStatus,
    required this.lastMessage,
    required this.lastAttemptAt,
    required this.lastSuccessAt,
    required this.pendingCount,
    required this.webhookController,
    required this.apiKeyController,
    required this.mappingControllers,
    required this.isTesting,
    required this.isRetrying,
    required this.onConfigure,
    required this.onTestConnection,
    required this.onRetryFailed,
    required this.onAutoSyncChanged,
  });

  final String name;
  final Color accent;
  final bool autoSync;
  final String lastStatus;
  final String lastMessage;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final int pendingCount;
  final TextEditingController webhookController;
  final TextEditingController apiKeyController;
  final Map<String, TextEditingController> mappingControllers;
  final bool isTesting;
  final bool isRetrying;
  final VoidCallback onConfigure;
  final VoidCallback onTestConnection;
  final VoidCallback onRetryFailed;
  final ValueChanged<bool> onAutoSyncChanged;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (lastStatus) {
      'success' => const Color(0xFF35C784),
      'failed' => const Color(0xFFD14343),
      _ => const Color(0xFF8B99AB),
    };
    final statusText = switch (lastStatus) {
      'success' => 'Last sync successful',
      'failed' => 'Last sync failed',
      _ => autoSync ? 'Auto-sync enabled' : 'Paused - Sync disabled',
    };
    final statusMeta = <String>[
      if (lastAttemptAt != null)
        'Attempted: ${lastAttemptAt!.toLocal().toString().split('.').first}',
      if (lastSuccessAt != null)
        'Success: ${lastSuccessAt!.toLocal().toString().split('.').first}',
      if (pendingCount > 0) 'Pending retries: $pendingCount',
    ].join(' | ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5EAF1)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                      ),
                    ),
                    if (statusMeta.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          statusMeta,
                          style: const TextStyle(
                            color: Color(0xFF8B99AB),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onConfigure,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D5BD7), foregroundColor: Colors.white),
                child: const Text('Configure'),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auto-Sync Leads', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF233655))),
                    SizedBox(height: 2),
                    Text('Push new leads automatically', style: TextStyle(color: Color(0xFF8B99AB), fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: autoSync, onChanged: onAutoSyncChanged),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: webhookController,
            decoration: const InputDecoration(
              labelText: 'Webhook URL',
              hintText: 'https://hooks.zapier.com/... or API Nation endpoint',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API Key (optional)',
              hintText: 'Bearer token for secured endpoints',
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: const Text(
              'Field Mapping',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Map lead fields to your CRM destination keys',
              style: TextStyle(fontSize: 12),
            ),
            children: [
              for (final field in _fieldMappings)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: mappingControllers[field.key],
                    decoration: InputDecoration(
                      labelText: '${field.label} destination key',
                      hintText: field.key,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (lastMessage.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F8FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                lastMessage,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4E6078)),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: onConfigure,
                child: const Text('Save Configuration'),
              ),
              OutlinedButton(
                onPressed: isTesting ? null : onTestConnection,
                child: Text(isTesting ? 'Testing...' : 'Test Sync'),
              ),
              OutlinedButton(
                onPressed: isRetrying || pendingCount == 0 ? null : onRetryFailed,
                child: Text(isRetrying ? 'Retrying...' : 'Retry Failed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrationDraft {
  _IntegrationDraft({
    required this.provider,
    required this.displayName,
    required this.accent,
    required this.autoSync,
    required this.lastStatus,
    required this.lastMessage,
    required this.lastAttemptAt,
    required this.lastSuccessAt,
    required this.webhookController,
    required this.apiKeyController,
    required this.mappingControllers,
  });

  final CrmProvider provider;
  final String displayName;
  final Color accent;
  final bool autoSync;
  final String lastStatus;
  final String lastMessage;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final TextEditingController webhookController;
  final TextEditingController apiKeyController;
  final Map<String, TextEditingController> mappingControllers;

  factory _IntegrationDraft.fromTarget(CrmSyncTarget target) {
    return _IntegrationDraft(
      provider: target.provider,
      displayName: target.displayName,
      accent: target.provider == CrmProvider.apiNation
          ? const Color(0xFFE8EEFF)
          : const Color(0xFFFFEEE8),
      autoSync: target.autoSync,
      lastStatus: target.lastStatus,
      lastMessage: target.lastMessage,
      lastAttemptAt: target.lastAttemptAt,
      lastSuccessAt: target.lastSuccessAt,
      webhookController: TextEditingController(text: target.webhookUrl),
      apiKeyController: TextEditingController(text: target.apiKey),
      mappingControllers: {
        for (final field in _fieldMappings)
          field.key: TextEditingController(
            text: target.fieldMappings[field.key] ?? field.key,
          ),
      },
    );
  }

  _IntegrationDraft copyWith({bool? autoSync}) {
    return _IntegrationDraft(
      provider: provider,
      displayName: displayName,
      accent: accent,
      autoSync: autoSync ?? this.autoSync,
      lastStatus: lastStatus,
      lastMessage: lastMessage,
      lastAttemptAt: lastAttemptAt,
      lastSuccessAt: lastSuccessAt,
      webhookController: webhookController,
      apiKeyController: apiKeyController,
      mappingControllers: mappingControllers,
    );
  }

  CrmSyncTarget toTarget() {
    return CrmSyncTarget(
      provider: provider,
      displayName: displayName,
      autoSync: autoSync,
      webhookUrl: webhookController.text.trim(),
      apiKey: apiKeyController.text.trim(),
      fieldMappings: {
        for (final field in _fieldMappings)
          field.key: (mappingControllers[field.key]?.text.trim().isNotEmpty ?? false)
              ? mappingControllers[field.key]!.text.trim()
              : field.key,
      },
      lastStatus: lastStatus,
      lastMessage: lastMessage,
      lastAttemptAt: lastAttemptAt,
      lastSuccessAt: lastSuccessAt,
    );
  }
}
