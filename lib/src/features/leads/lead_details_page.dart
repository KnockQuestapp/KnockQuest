import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../sample_data.dart';
import '../../state/lead_store.dart';

class LeadDetailsPage extends StatelessWidget {
  const LeadDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lead = LeadStore.instance.latestLead;

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
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      const Expanded(
                        child: Text('Lead Details', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD7E4FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Text('JD', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF233655)))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lead.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF233655)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFE8F4EA), borderRadius: BorderRadius.circular(999)),
                                    child: Text(
                                      lead.status,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Color(0xFF3B8F52), fontSize: 11),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(lead.address, style: const TextStyle(color: Color(0xFF7E8CA0))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Building Units', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: const [
                      _UnitChip('101'),
                      _UnitChip('102', selected: true),
                      _UnitChip('103'),
                      _UnitChip('201'),
                      _UnitChip('202'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.visitHistory),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D5BD7), foregroundColor: Colors.white),
                          child: const Text('Log Visit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.followUps),
                          child: const Text('Follow Up'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5EAF1)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('Property Info', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF7E8CA0)))),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(child: _InfoPair('Building Type', 'Condo / Apartment')),
                            SizedBox(width: 16),
                            Expanded(child: _InfoPair('Ownership', 'Owner Occupied')),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(child: _InfoPair('Lead Source', lead.outcome)),
                            const SizedBox(width: 16),
                            Expanded(child: _InfoPair('Est. Value', lead.estimatedValue)),
                          ],
                        ),
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

class _UnitChip extends StatelessWidget {
  const _UnitChip(this.label, {this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1D5BD7) : Colors.white,
        border: Border.all(color: const Color(0xFFE1E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : const Color(0xFF506178))),
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9AA7BA), fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF233655), fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
