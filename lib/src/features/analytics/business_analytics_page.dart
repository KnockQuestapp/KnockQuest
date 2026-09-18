import 'package:flutter/material.dart';
import '../../sample_data.dart';
import '../../state/lead_store.dart';

class BusinessAnalyticsPage extends StatefulWidget {
  const BusinessAnalyticsPage({super.key});

  @override
  State<BusinessAnalyticsPage> createState() => _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends State<BusinessAnalyticsPage> {
  String _period = 'This Month';

  List<LeadRecord> _visibleLeads(List<LeadRecord> leads) {
    if (_period == 'All Time') return leads;
    final now = DateTime.now();
    return leads.where((lead) {
      final date = lead.lastContactDate;
      if (_period == 'This Year') return date.year == now.year;
      return date.year == now.year && date.month == now.month;
    }).toList();
  }

  double _estimatedValue(List<LeadRecord> leads) {
    double total = 0;
    for (final lead in leads) {
      final valueString = lead.estimatedValue.replaceAll(RegExp(r'[$,]'), '');
      total += double.tryParse(valueString) ?? 0;
    }
    return total;
  }

  Map<String, String> _calculateMetrics(List<LeadRecord> leads) {
    final total = _estimatedValue(leads);

    final closedLeads = leads
        .where((l) => l.status == LeadStatus.closed)
        .length;
    final conversionRate = leads.isEmpty
        ? 0.0
        : (closedLeads / leads.length) * 100;

    return {
      'value': r'$' + total.toStringAsFixed(2),
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
                final visibleLeads = _visibleLeads(leads);
                final metrics = _calculateMetrics(visibleLeads);

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
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Estimated Pipeline Value',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withValues(alpha: 0.88),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                metrics['value']!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Last Contact: $_period',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary
                                      .withValues(alpha: 0.88),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _AnalyticsSmall(
                                  metrics['count']!,
                                  'Total Leads',
                                ),
                                _AnalyticsSmall(
                                  metrics['rate']!,
                                  'Conversion Rate',
                                ),
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
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
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
                                      value: visibleLeads.isEmpty
                                          ? 0
                                          : (visibleLeads
                                                    .where(
                                                      (l) =>
                                                          l.status ==
                                                          LeadStatus.closed,
                                                    )
                                                    .length /
                                                visibleLeads.length),
                                      strokeWidth: 28,
                                      valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                    ),
                                    SizedBox(
                                      width: 92,
                                      height: 92,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).scaffoldBackgroundColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _LegendRow(
                              Theme.of(context).colorScheme.primary,
                              'Closed',
                              '\$${_estimatedValue(visibleLeads.where((l) => l.status == LeadStatus.closed).toList()).toStringAsFixed(2)}',
                              '${visibleLeads.where((l) => l.status == LeadStatus.closed).length} leads',
                            ),
                            _LegendRow(
                              Theme.of(context).colorScheme.secondary,
                              'Active',
                              '\$${_estimatedValue(visibleLeads.where((l) => l.status != LeadStatus.closed).toList()).toStringAsFixed(2)}',
                              '${visibleLeads.where((l) => l.status != LeadStatus.closed).length} leads',
                            ),
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
          color: selected ? const Color(0xFF1D5BD7) : Colors.transparent,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.78),
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              source,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
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
