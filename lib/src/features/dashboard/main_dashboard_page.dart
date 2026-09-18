import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_routes.dart';
import '../../integrations/crm_sync_store.dart';
import '../../sample_data.dart';
import '../../state/lead_store.dart';
import '../../state/auth_store.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  @override
  void initState() {
    super.initState();
    CrmSyncStore.instance.ensureLoaded();
  }

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

  Future<void> _signOut() async {
    await AuthStore.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobileViewport = MediaQuery.sizeOf(context).width < 720;
    final contentPadding = EdgeInsets.fromLTRB(16, 16, 16, 128);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: contentPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KNOCKQUEST / FIELD HQ',
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d').format(DateTime.now()),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: widget.onThemeToggle,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              padding: const EdgeInsets.all(10),
                            ),
                            icon: Icon(
                              widget.isDarkMode
                                  ? Icons.light_mode_outlined
                                  : Icons.dark_mode_outlined,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Sign out',
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _DashboardHero(
                    name: AuthStore.instance.currentUser.value?.name ?? 'Agent',
                    onAddLead: _openAddLead,
                    onOpenMap: () =>
                        Navigator.pushNamed(context, AppRoutes.interactiveMap),
                  ),
                  const SizedBox(height: 22),
                  if (!isMobileViewport)
                    Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.person_add_alt_1,
                            color: Theme.of(context).colorScheme.primary,
                            label: 'Add Lead',
                            onTap: _openAddLead,
                          ),
                        ),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.map_outlined,
                            color: Theme.of(context).colorScheme.secondary,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
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
                            color: Theme.of(context).colorScheme.tertiary,
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
                  _CrmReadinessBanner(
                    onOpenIntegrations: () =>
                        Navigator.pushNamed(context, AppRoutes.integrations),
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle('Sales Performance'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<LeadRecord>>(
                    valueListenable: LeadStore.instance.leads,
                    builder: (context, leads, _) => _MetricGrid(leads: leads),
                  ),
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
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.quests),
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

class _CrmReadinessBanner extends StatelessWidget {
  const _CrmReadinessBanner({required this.onOpenIntegrations});

  final VoidCallback onOpenIntegrations;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CrmSyncTarget>>(
      valueListenable: CrmSyncStore.instance.targets,
      builder: (context, targets, _) {
        final configuredTargets = targets
            .where((target) => target.webhookUrl.trim().isNotEmpty)
            .toList();
        final activeTargets = configuredTargets
            .where((target) => target.autoSync)
            .toList();
        final failedTargets = activeTargets
            .where((target) => target.lastStatus == 'failed')
            .toList();

        return ValueListenableBuilder<List<CrmSyncRetryItem>>(
          valueListenable: CrmSyncStore.instance.retryQueue,
          builder: (context, retryItems, child) {
            final pendingCount = retryItems.length;

            Color backgroundColor;
            Color borderColor;
            Color titleColor;
            IconData icon;
            String title;
            String subtitle;

            if (activeTargets.isEmpty) {
              backgroundColor = const Color(0xFFFFF8E8);
              borderColor = const Color(0xFFFFD98C);
              titleColor = const Color(0xFF8A5A00);
              icon = Icons.info_outline;
              title = 'CRM sync not fully set up';
              subtitle = configuredTargets.isEmpty
                  ? 'Connect API Nation or Zapier to enable automatic lead sync.'
                  : 'Enable Auto-Sync on at least one integration to push leads automatically.';
            } else if (failedTargets.isNotEmpty || pendingCount > 0) {
              backgroundColor = const Color(0xFFFFF1F1);
              borderColor = const Color(0xFFF4B6B6);
              titleColor = const Color(0xFF9E1F1F);
              icon = Icons.error_outline;
              title = 'CRM sync needs attention';
              subtitle = pendingCount > 0
                  ? '$pendingCount sync event(s) waiting for retry.'
                  : 'At least one integration reported a sync failure.';
            } else {
              backgroundColor = const Color(0xFFEFFAF4);
              borderColor = const Color(0xFFB8E7CB);
              titleColor = const Color(0xFF1E7A47);
              icon = Icons.check_circle_outline;
              title = 'CRM sync is healthy';
              subtitle =
                  '${activeTargets.length} integration(s) actively syncing leads.';
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(icon, color: titleColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF4E6078),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onOpenIntegrations,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1E40AF),
                    ),
                    child: const Text('Manage'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.name,
    required this.onAddLead,
    required this.onOpenMap,
  });

  final String name;
  final VoidCallback onAddLead;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final firstName = name.trim().split(' ').first;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF214BE0), Color(0xFF172C85), Color(0xFF101D53)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -64,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .18),
                  width: 28,
                ),
              ),
            ),
          ),
          Positioned(
            right: 36,
            bottom: -70,
            child: Icon(
              Icons.location_on_rounded,
              size: 210,
              color: const Color(0xFF9FEADD).withValues(alpha: .14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '✦  YOUR NEXT MOVE STARTS HERE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Hey, $firstName.\nOwn your area.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    height: 1.02,
                    letterSpacing: -1.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'Every door is a new opportunity. Let’s get moving.',
                  style: TextStyle(
                    color: Color(0xFFE1E8FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 25),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onAddLead,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add a lead'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDF9F1),
                        foregroundColor: const Color(0xFF092C39),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: onOpenMap,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Explore map'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF9FB5FC)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    Color iconColorFor(Color bg) {
      if (bg == colorScheme.primary) return colorScheme.onPrimary;
      if (bg == colorScheme.secondary) return colorScheme.onSecondary;
      if (bg == colorScheme.tertiary) return colorScheme.onTertiary;
      if (bg == colorScheme.surfaceContainerHighest) {
        return colorScheme.onSurface;
      }
      return colorScheme.onPrimary;
    }

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
            child: Icon(icon, color: iconColorFor(color)),
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
      style: TextStyle(
        fontSize: 22,
        letterSpacing: -.5,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<LeadRecord> leads;
  const _MetricGrid({required this.leads});

  @override
  Widget build(BuildContext context) {
    final pipelineValue = leads.fold<double>(0, (total, lead) {
      final raw = lead.estimatedValue.replaceAll(RegExp(r'[^0-9.]'), '');
      return total + (double.tryParse(raw) ?? 0);
    });
    final closedCount = leads
        .where((lead) => lead.status == LeadStatus.closed)
        .length;
    final conversionRate = leads.isEmpty
        ? 0.0
        : closedCount / leads.length * 100;

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 4 : 2,
      childAspectRatio: 1.0,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _MetricCard(
          NumberFormat.compactCurrency(symbol: '\$').format(pipelineValue),
          'Est. Pipeline',
          Icons.attach_money_outlined,
        ),
        _MetricCard('${leads.length}', 'Total Leads', Icons.people_outline),
        _MetricCard(
          '${conversionRate.toStringAsFixed(1)}%',
          'Conv. Rate',
          Icons.trending_up,
        ),
        _MetricCard('N/A', 'Avg / Deal', Icons.stacked_bar_chart_outlined),
      ],
    );
  }
}

String _formatCompactNumber(String raw) {
  if (raw.contains('\$') || raw.contains('%') || raw.endsWith('K')) {
    return raw;
  }
  // remove non-numeric except decimal
  final cleaned = raw.replaceAll(RegExp('[^0-9.]'), '');
  if (cleaned.isEmpty) return raw;
  final value = double.tryParse(cleaned) ?? 0;
  if (value < 1000) {
    // return integer if whole, otherwise keep as-is without extra decimals
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
  final k = value / 1000.0;
  var out = k.toStringAsFixed(1);
  // remove trailing .0
  if (out.endsWith('.0')) out = out.substring(0, out.length - 2);
  return '${out}K';
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
      crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 4 : 2,
      childAspectRatio: 1.0,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _MetricCard('$totalLeads', 'Total Leads', Icons.groups_2_outlined),
        _MetricCard('$activeLeads', 'Active Leads', Icons.bolt_outlined),
        _MetricCard('$prospects', 'Prospects', Icons.star_outline),
        _MetricCard(
          '$followUpsDue',
          'Follow Ups Due Today',
          Icons.task_alt_outlined,
        ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatCompactNumber(value),
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
