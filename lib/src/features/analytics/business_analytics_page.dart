import 'package:flutter/material.dart';
import '../../state/lead_store.dart';
import '../../services/supabase_service.dart';

class BusinessAnalyticsPage extends StatefulWidget {
  const BusinessAnalyticsPage({super.key});

  @override
  State<BusinessAnalyticsPage> createState() => _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends State<BusinessAnalyticsPage> {
  String _period = 'This Month';
  Map<String, dynamic>? _globalMetrics;

  @override
  void initState() {
    super.initState();
    _loadGlobalMetrics();
  }

  Future<void> _loadGlobalMetrics() async {
    final metrics = await SupabaseService.instance.fetchGlobalMetrics();
    setState(() {
      _globalMetrics = metrics;
    });
  }

  Map<String, String> _calculateMetrics() {
    if (_period == 'All Time' && _globalMetrics != null) {
      return {
        'gci': r'$' + (_globalMetrics!['total_gci'] as double).toStringAsFixed(2),
        'count': '${_globalMetrics!['total_leads']} leads',
        'rate': '${(_globalMetrics!['conversion_rate'] as double).toStringAsFixed(1)}%',
      };
    }

    final leads = LeadStore.instance.leads.value;

    // Sum up estimated value
    double totalGci = 0;
    for (final lead in leads) {
      final valueString = lead.estimatedValue.replaceAll(RegExp(r'[$,]'), '');
      totalGci += double.tryParse(valueString) ?? 0;
    }

    final closedLeads = leads.where((l) => l.status.toLowerCase().contains('closed')).length;
    final conversionRate = leads.isEmpty
        ? 0.0
        : (closedLeads / leads.length) * 100;

    return {
      'gci': r'$' + totalGci.toStringAsFixed(2),
      'count': '${leads.length} leads',
      'rate': '${conversionRate.toStringAsFixed(1)}%',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ValueListenableBuilder<List<LeadRecord>>(
              valueListenable: LeadStore.instance.leads,
              builder: (context, leads, _) {
                final metrics = _calculateMetrics();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Business Analytics',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const Icon(Icons.tune),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            'This Month',
                            selected: _period == 'This Month',
                            onTap: () => setState(() => _period = 'This Month'),
                          ),
                          _FilterChip(
                            'This Year',
                            selected: _period == 'This Year',
                            onTap: () => setState(() => _period = 'This Year'),
                          ),
                          _FilterChip(
                            'All Time',
                            selected: _period == 'All Time',
                            onTap: () => setState(() => _period = 'All Time'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Total GCI Performance',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 224),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(metrics['gci']!, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 42, fontWeight: FontWeight.w700)),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'GCI $_period',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 224),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _AnalyticsSmall(metrics['count']!, 'Total Leads'),
                                _AnalyticsSmall(metrics['rate']!, 'Conversion Rate'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).dividerColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leads By Status',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: leads.isEmpty ? 0 : (leads.where((l) => l.status.toLowerCase().contains('closed')).length / leads.length),
                                      strokeWidth: 28,
                                      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    ),
                                    SizedBox(
                                      width: 92,
                                      height: 92,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _LegendRow(Theme.of(context).colorScheme.primary, 'Closed', metrics['gci']!, '${leads.where((l) => l.status.toLowerCase().contains('closed')).length} leads'),
                            _LegendRow(Theme.of(context).colorScheme.secondary, 'Active', '\$0.00', '${leads.where((l) => !l.status.toLowerCase().contains('closed')).length} leads'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.text, {this.selected = false, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF3F9) : Colors.transparent,
          border: Border.all(color: const Color(0xFFE1E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}

class _AnalyticsSmall extends StatelessWidget {
  const _AnalyticsSmall(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 199),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(this.color, this.source, this.amount, this.count);

  final Color color;
  final String source;
  final String amount;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              source,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
