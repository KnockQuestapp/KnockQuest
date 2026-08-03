import 'package:flutter/material.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _QuestTile(
          title: 'Park Cleanup Patrol',
          status: 'Draft',
          details: 'Seed quest used for migration verification and UI smoke checks.',
        ),
        _QuestTile(
          title: 'Community Food Drive',
          status: 'Planned',
          details: 'Next feature milestone after map routing and account migration.',
        ),
      ],
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.title,
    required this.status,
    required this.details,
  });

  final String title;
  final String status;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(details),
        trailing: Chip(label: Text(status)),
      ),
    );
  }
}
