import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../state/lead_store.dart';
import '../../sample_data.dart';

class VisitLoggerHistoryPage extends StatefulWidget {
  const VisitLoggerHistoryPage({super.key});

  @override
  State<VisitLoggerHistoryPage> createState() => _VisitLoggerHistoryPageState();
}

class _VisitLoggerHistoryPageState extends State<VisitLoggerHistoryPage> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedOutcome = 'Spoke To Owner';
  String _leadStatus = 'Active Lead';
  final List<_VisitEntry> _history = [
    const _VisitEntry(
      title: 'Appointment Set',
      date: 'Oct 24, 2023',
      meta: 'Alex Rivera • 2:15 PM',
      details:
          'Owner is interested in a valuation. Set appointment for next Tuesday at 5 PM.',
    ),
    const _VisitEntry(
      title: 'Spoke To Owner',
      date: 'Oct 20, 2023',
      meta: 'Alex Rivera • 11:05 AM',
      details:
          'Had a good chat about the neighborhood market. They are not ready to sell today but might be in the next 6 months.',
    ),
  ];

  static const _statusOptions = [
    'Active Lead',
    'Warm Lead',
    'Qualified',
    'Do Not Contact',
  ];

  @override
  void initState() {
    super.initState();
    _leadStatus = LeadStore.instance.latestLead.status;
  }

  void _logVisit() {
    final notes = _notesController.text.trim();
    final message = notes.isEmpty
        ? 'Visit logged: $_selectedOutcome'
        : 'Visit logged: $_selectedOutcome - $notes';

    final now = DateTime.now();
    final month = _monthAbbr(now.month);
    final day = now.day.toString().padLeft(2, '0');
    final hour12 = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timestamp = '$hour12:$minute $ampm';

    setState(() {
      _history.insert(
        0,
        _VisitEntry(
          title: _selectedOutcome,
          date: '$month $day, ${now.year}',
          meta: '${LeadStore.instance.latestLead.name} • $timestamp',
          details: notes.isEmpty ? 'No additional notes added.' : notes,
        ),
      );
    });

    LeadStore.instance.updateLatestLead(
      outcome: _selectedOutcome,
      notes: notes.isEmpty ? LeadStore.instance.latestLead.notes : notes,
      lastContactDate: now,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addFollowUp() {
    final notes = _notesController.text.trim();
    LeadStore.instance.addFollowUp(
      FollowUpRecord(
        name: LeadStore.instance.latestLead.name,
        address: LeadStore.instance.latestLead.address,
        note: notes.isEmpty ? _selectedOutcome : notes,
        when: 'Today',
        priorityColor: Theme.of(context).colorScheme.primary.toARGB32(),
      ),
    );

    LeadStore.instance.updateLatestLead(
      outcome: _selectedOutcome,
      notes: notes.isEmpty ? LeadStore.instance.latestLead.notes : notes,
      lastContactDate: DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Follow up added successfully.')),
    );
  }

  void _changeStatus() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Change Lead Status',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final status in _statusOptions)
                ListTile(
                  title: Text(status),
                  trailing: status == _leadStatus
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _leadStatus = status;
                    });
                    LeadStore.instance.updateLatestLead(status: status);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lead status changed to $status.')),
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _viewOnMap() {
    Navigator.pushNamed(context, AppRoutes.interactiveMap);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lead = LeadStore.instance.latestLead;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              lead.address,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lead.name} - $_leadStatus',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
                        child: Text(
                          'Visit #4',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Log New Visit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _OutcomeTag('No Answer', selected: _selectedOutcome == 'No Answer', onTap: () => setState(() => _selectedOutcome = 'No Answer')),
                      _OutcomeTag('Spoke To Owner', selected: _selectedOutcome == 'Spoke To Owner', onTap: () => setState(() => _selectedOutcome = 'Spoke To Owner')),
                      _OutcomeTag('Interested', selected: _selectedOutcome == 'Interested', onTap: () => setState(() => _selectedOutcome = 'Interested')),
                      _OutcomeTag('Not Interested', selected: _selectedOutcome == 'Not Interested', onTap: () => setState(() => _selectedOutcome = 'Not Interested')),
                      _OutcomeTag('Follow Up Later', selected: _selectedOutcome == 'Follow Up Later', onTap: () => setState(() => _selectedOutcome = 'Follow Up Later')),
                      _OutcomeTag('Appointment Set', selected: _selectedOutcome == 'Appointment Set', onTap: () => setState(() => _selectedOutcome = 'Appointment Set')),
                      _OutcomeTag('Do Not Solicit', selected: _selectedOutcome == 'Do Not Solicit', onTap: () => setState(() => _selectedOutcome = 'Do Not Solicit')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Visit Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Enter details about the conversation...',
                      prefixIcon: Icon(Icons.mail_outline, size: 18, color: Theme.of(context).textTheme.bodySmall?.color),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _logVisit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: const Text('Log Visit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(onPressed: _addFollowUp, child: const Text('Add Follow Up')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        'Visit History',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: ${_history.length}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return _VisitHistoryTile(
                          item.title,
                          item.date,
                          item.meta,
                          item.details,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: _viewOnMap, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondaryContainer, foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer), child: const Text('View on Map'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextButton(onPressed: _changeStatus, child: const Text('Change Status'))),
                    ],
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

class _VisitEntry {
  const _VisitEntry({
    required this.title,
    required this.date,
    required this.meta,
    required this.details,
  });

  final String title;
  final String date;
  final String meta;
  final String details;
}

String _monthAbbr(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) {
    return 'Jan';
  }
  return months[month - 1];
}

class _OutcomeTag extends StatelessWidget {
  const _OutcomeTag(this.text, {required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _VisitHistoryTile extends StatelessWidget {
  const _VisitHistoryTile(this.title, this.date, this.meta, this.details);

  final String title;
  final String date;
  final String meta;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 72, color: Theme.of(context).dividerColor),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  details,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
