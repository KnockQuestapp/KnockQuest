import 'package:flutter/material.dart';

import '../../sample_data.dart';
import '../../state/lead_store.dart';

class FollowUpsPage extends StatefulWidget {
  const FollowUpsPage({super.key});

  @override
  State<FollowUpsPage> createState() => _FollowUpsPageState();
}

class _FollowUpsPageState extends State<FollowUpsPage> {
  void _completeFollowUp(int index) {
    LeadStore.instance.markFollowUpCompleted(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Follow up marked completed.')),
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
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Follow Ups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                            SizedBox(height: 6),
                            Text('Stay on top of your leads', style: TextStyle(color: Color(0xFF8B99AB))),
                          ],
                        ),
                      ),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month_outlined)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DayChip('Mon', '12'),
                      _DayChip('Tue', '13'),
                      _DayChip('Wed', '14', selected: true),
                      _DayChip('Thu', '15'),
                      _DayChip('Fri', '16'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Overdue', style: TextStyle(color: Color(0xFFFF6633), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ValueListenableBuilder<List<FollowUpRecord>>(
                      valueListenable: LeadStore.instance.followUpsNotifier,
                      builder: (context, items, _) {
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _FollowUpCard(
                              item: item,
                              onComplete: () => _completeFollowUp(index),
                            );
                          },
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

class _DayChip extends StatelessWidget {
  const _DayChip(this.day, this.date, {this.selected = false});

  final String day;
  final String date;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF1D5BD7) : Colors.white,
        border: Border.all(color: const Color(0xFFE1E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(day, style: TextStyle(color: selected ? Colors.white : const Color(0xFF506178), fontSize: 11)),
          const SizedBox(height: 2),
          Text(date, style: TextStyle(color: selected ? Colors.white : const Color(0xFF233655), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.item, required this.onComplete});

  final FollowUpRecord item;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: item.completed ? const Color(0xFFC9EED8) : const Color(0xFFFFC3B0),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 42, color: Color(item.priorityColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF233655)))),
                    Text(item.when, style: const TextStyle(color: Color(0xFFFF6633), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.address, style: const TextStyle(color: Color(0xFF7E8CA0), fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  item.note,
                  style: TextStyle(
                    color: const Color(0xFF7E8CA0),
                    fontSize: 12,
                    decoration: item.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: item.completed ? null : onComplete,
            icon: Icon(
              item.completed ? Icons.check_circle : Icons.task_alt_outlined,
              color: item.completed ? const Color(0xFF35C784) : null,
            ),
          ),
        ],
      ),
    );
  }
}
