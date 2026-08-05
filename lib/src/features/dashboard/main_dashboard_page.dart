import 'package:flutter/material.dart';

import '../../app_routes.dart';
import '../../sample_data.dart';
import '../../state/lead_store.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  Future<void> _openAddLead() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addLead);
    if (!mounted) {
      return;
    }

    if (result is Map<String, dynamic>) {
      final firstName = (result['firstName'] as String?)?.trim() ?? '';
      final lastName = (result['lastName'] as String?)?.trim() ?? '';
      final displayName = '$firstName $lastName'.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            displayName.isEmpty
                ? 'Lead saved successfully.'
                : 'Lead saved: $displayName',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobileViewport = MediaQuery.sizeOf(context).width < 720;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Good Morning, Sarah',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF233655),
                              ),
                            ),
                            Text(
                              'Monday, June 12',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: const Color(0xFF8B99AB)),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (!isMobileViewport)
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_add_alt_1,
                            color: const Color(0xFF1D5BD7),
                            label: 'Add Lead',
                            onTap: _openAddLead,
                          ),
                        ),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.map_outlined,
                            color: const Color(0xFF13B7D8),
                            label: 'Open Map',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.interactiveMap,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.calendar_today_outlined,
                            color: const Color(0xFF52627C),
                            label: 'Follow Ups',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.followUps,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.ios_share_outlined,
                            color: const Color(0xFF35C784),
                            label: 'Export',
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.analytics,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _SectionTitle('Sales Performance'),
                  const SizedBox(height: 12),
                  const _MetricGrid(),
                  const SizedBox(height: 20),
                  _SectionTitle('Lead Pipeline'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<LeadRecord>>(
                    valueListenable: LeadStore.instance.leads,
                    builder: (context, leads, _) {
                      return _PipelineGrid(totalLeads: leads.length);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.territories,
                          ),
                          child: const Text('Territories'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.integrations,
                          ),
                          child: const Text('CRM & Integrations'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.subscriptions,
                          ),
                          child: const Text('Subscription & Themes'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.quests,
                          ),
                          child: const Text('Quests'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.leadDetails,
                          ),
                          child: const Text('Lead Details'),
                        ),
                      ),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF506178),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
                      childAspectRatio: 1.55,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: const [
        _MetricCard('142,500', 'Closed Revenue', Icons.attach_money_outlined),
        _MetricCard('12,400', 'Closed Revenue This Month', Icons.payments_outlined),
        _MetricCard('18', 'Closed Deals', Icons.location_on_outlined),
        _MetricCard('7,916', 'Avg Revenue / Deal', Icons.stacked_bar_chart_outlined),
      ],
    );
  }
}

class _PipelineGrid extends StatelessWidget {
  const _PipelineGrid({required this.totalLeads});

  final int totalLeads;

  @override
  Widget build(BuildContext context) {
    final activeLeads = totalLeads;
    final prospects = (totalLeads / 2).ceil();
    final followUpsDue = (totalLeads / 3).ceil();

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.15,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _MetricCard('$totalLeads', 'Total Leads', Icons.groups_2_outlined),
        _MetricCard('$activeLeads', 'Active Leads', Icons.bolt_outlined),
        _MetricCard('$prospects', 'Prospects', Icons.star_outline),
        _MetricCard('$followUpsDue', 'Follow Ups Due Today', Icons.task_alt_outlined),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5EAF1)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF35C784), size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF233655),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
