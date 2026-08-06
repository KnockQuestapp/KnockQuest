import 'package:flutter/material.dart';

import '../../integrations/crm_sync_service.dart';
import '../../integrations/crm_sync_store.dart';

class CrmIntegrationsPage extends StatefulWidget {
  const CrmIntegrationsPage({super.key});

  @override
  State<CrmIntegrationsPage> createState() => _CrmIntegrationsPageState();
}

class _CrmIntegrationsPageState extends State<CrmIntegrationsPage> {
  bool _isLoading = true;
  final Set<CrmProvider> _testingProviders = <CrmProvider>{};
  List<_IntegrationDraft> _drafts = <_IntegrationDraft>[];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.webhookController.dispose();
      draft.apiKeyController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await CrmSyncStore.instance.ensureLoaded();
    if (!mounted) {
      return;
    }

    setState(() {
      _drafts = CrmSyncStore.instance.targets.value
          .map((target) => _IntegrationDraft.fromTarget(target))
          .toList();
      _isLoading = false;
    });
  }

  void _toggleSync(int index, bool value) {
    setState(() {
      _drafts[index] = _drafts[index].copyWith(autoSync: value);
    });
  }

  Future<void> _configure(int index) async {
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
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${target.displayName} configuration saved.')),
    );
  }

  Future<void> _testConnection(int index) async {
    final provider = _drafts[index].provider;
    await _configure(index);
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    child: ListView.separated(
                      itemCount: _drafts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _drafts[index];
                        return _CrmCard(
                          name: item.displayName,
                          accent: item.accent,
                          autoSync: item.autoSync,
                          webhookController: item.webhookController,
                          apiKeyController: item.apiKeyController,
                          isTesting: _testingProviders.contains(item.provider),
                          onConfigure: () => _configure(index),
                          onTestConnection: () => _testConnection(index),
                          onAutoSyncChanged: (value) => _toggleSync(index, value),
                        );
                      },
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
    required this.webhookController,
    required this.apiKeyController,
    required this.isTesting,
    required this.onConfigure,
    required this.onTestConnection,
    required this.onAutoSyncChanged,
  });

  final String name;
  final Color accent;
  final bool autoSync;
  final TextEditingController webhookController;
  final TextEditingController apiKeyController;
  final bool isTesting;
  final VoidCallback onConfigure;
  final VoidCallback onTestConnection;
  final ValueChanged<bool> onAutoSyncChanged;

  @override
  Widget build(BuildContext context) {
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
                      autoSync ? 'Active - Last sync 2m ago' : 'Paused - Sync disabled',
                      style: TextStyle(
                        color: autoSync ? const Color(0xFF35C784) : const Color(0xFF8B99AB),
                        fontSize: 12,
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
          Row(
            children: [
              TextButton(
                onPressed: onConfigure,
                child: const Text('Save Configuration'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: isTesting ? null : onTestConnection,
                child: Text(isTesting ? 'Testing...' : 'Test Sync'),
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
    required this.webhookController,
    required this.apiKeyController,
  });

  final CrmProvider provider;
  final String displayName;
  final Color accent;
  final bool autoSync;
  final TextEditingController webhookController;
  final TextEditingController apiKeyController;

  factory _IntegrationDraft.fromTarget(CrmSyncTarget target) {
    return _IntegrationDraft(
      provider: target.provider,
      displayName: target.displayName,
      accent: target.provider == CrmProvider.apiNation
          ? const Color(0xFFE8EEFF)
          : const Color(0xFFFFEEE8),
      autoSync: target.autoSync,
      webhookController: TextEditingController(text: target.webhookUrl),
      apiKeyController: TextEditingController(text: target.apiKey),
    );
  }

  _IntegrationDraft copyWith({bool? autoSync}) {
    return _IntegrationDraft(
      provider: provider,
      displayName: displayName,
      accent: accent,
      autoSync: autoSync ?? this.autoSync,
      webhookController: webhookController,
      apiKeyController: apiKeyController,
    );
  }

  CrmSyncTarget toTarget() {
    return CrmSyncTarget(
      provider: provider,
      displayName: displayName,
      autoSync: autoSync,
      webhookUrl: webhookController.text.trim(),
      apiKey: apiKeyController.text.trim(),
    );
  }
}
