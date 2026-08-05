import 'package:flutter/material.dart';

class BusinessAnalyticsPage extends StatefulWidget {
  const BusinessAnalyticsPage({super.key});

  @override
  State<BusinessAnalyticsPage> createState() => _BusinessAnalyticsPageState();
}

class _BusinessAnalyticsPageState extends State<BusinessAnalyticsPage> {
  String _period = 'This Month';

  Map<String, String> get _metrics {
    switch (_period) {
      case 'This Year':
        return {
          'gci': r'$142,500.00',
          'avg': '12,400',
          'rate': '4.8%',
        };
      case 'All Time':
        return {
          'gci': r'$463,920.00',
          'avg': '9,870',
          'rate': '5.4%',
        };
      case 'This Month':
      default:
        return {
          'gci': r'$32,700.00',
          'avg': '10,900',
          'rate': '4.2%',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _metrics;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(child: Text('Business Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655)))),
                      Icon(Icons.tune),
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
                      gradient: const LinearGradient(colors: [Color(0xFF1D5BD7), Color(0xFF16C0E4)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('Total GCI Performance', style: TextStyle(color: Color(0xFFDBE7FF), fontSize: 12)),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(metrics['gci']!, style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w700)),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('GCI $_period', style: TextStyle(color: Color(0xFFDBE7FF))),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AnalyticsSmall(metrics['avg']!, 'Avg GCI / Deal'),
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
                      border: Border.all(color: const Color(0xFFE5EAF1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Leads By Source', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
                        const SizedBox(height: 18),
                        Center(
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(value: .38, strokeWidth: 28, valueColor: const AlwaysStoppedAnimation(Color(0xFF1D5BD7)), backgroundColor: const Color(0xFF445575)),
                                const SizedBox(
                                  width: 92,
                                  height: 92,
                                  child: DecoratedBox(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _LegendRow(Color(0xFF1D5BD7), 'Door Knocking', '\$64,200', '124 leads'),
                        const _LegendRow(Color(0xFF16C0E4), 'Referral', '\$38,000', '42 leads'),
                        const _LegendRow(Color(0xFF35C784), 'Facebook', '\$14,500', '18 leads'),
                      ],
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
        child: Text(text, style: const TextStyle(color: Color(0xFF506178))),
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
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Color(0xFFDBE7FF), fontSize: 12)),
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
          Expanded(child: Text(source, style: const TextStyle(color: Color(0xFF506178)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF233655))),
              Text(count, style: const TextStyle(color: Color(0xFF8B99AB), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
