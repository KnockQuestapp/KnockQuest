import 'package:flutter/material.dart';

class CrmIntegrationsPage extends StatefulWidget {
  const CrmIntegrationsPage({super.key});

  @override
  State<CrmIntegrationsPage> createState() => _CrmIntegrationsPageState();
}

class _CrmIntegrationsPageState extends State<CrmIntegrationsPage> {
  final List<_IntegrationConfig> _integrations = [
    _IntegrationConfig(name: 'Salesforce', accent: const Color(0xFFE8EEFF)),
    _IntegrationConfig(name: 'HubSpot', accent: const Color(0xFFFFEEE8)),
  ];

  void _toggleSync(int index, bool value) {
    setState(() {
      _integrations[index] = _integrations[index].copyWith(autoSync: value);
    });
  }

  void _configure(int index) {
    final name = _integrations[index].name;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name configuration saved.')),
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
                  const Text('Sync your leads and activities with your favorite tools.', style: TextStyle(color: Color(0xFF8B99AB))),
                  const SizedBox(height: 24),
                  const Text('Connected Services', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _integrations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _integrations[index];
                        return _CrmCard(
                          name: item.name,
                          accent: item.accent,
                          autoSync: item.autoSync,
                          onConfigure: () => _configure(index),
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
    required this.onConfigure,
    required this.onAutoSyncChanged,
  });

  final String name;
  final Color accent;
  final bool autoSync;
  final VoidCallback onConfigure;
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
          TextButton(onPressed: onConfigure, child: const Text('Map Custom Fields')),
        ],
      ),
    );
  }
}

class _IntegrationConfig {
  const _IntegrationConfig({
    required this.name,
    required this.accent,
    this.autoSync = true,
  });

  final String name;
  final Color accent;
  final bool autoSync;

  _IntegrationConfig copyWith({
    String? name,
    Color? accent,
    bool? autoSync,
  }) {
    return _IntegrationConfig(
      name: name ?? this.name,
      accent: accent ?? this.accent,
      autoSync: autoSync ?? this.autoSync,
    );
  }
}
