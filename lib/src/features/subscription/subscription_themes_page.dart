import 'package:flutter/material.dart';

class SubscriptionThemesPage extends StatefulWidget {
  const SubscriptionThemesPage({super.key});

  @override
  State<SubscriptionThemesPage> createState() => _SubscriptionThemesPageState();
}

class _SubscriptionThemesPageState extends State<SubscriptionThemesPage> {
  String _selectedPlan = 'Professional';

  void _choosePlan(String plan) {
    setState(() {
      _selectedPlan = plan;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan updated: $plan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          'Subscription & Themes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your KnockQuest experience',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select a Plan',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _PlanCard(
                          title: 'Free',
                          price: '\$0',
                          detail: 'Basic mapping, 50 leads, Light theme',
                          current: _selectedPlan == 'Free',
                          onPressed: () => _choosePlan('Free'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PlanCard(
                          title: 'Professional',
                          price: '\$29',
                          detail: 'Unlimited leads, CRM sync, Route optimization',
                          current: _selectedPlan == 'Professional',
                          onPressed: () => _choosePlan('Professional'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PlanCard(
                    title: 'Team',
                    price: '\$99',
                    detail: 'Multi-user access, team dashboards, territory sharing',
                    current: _selectedPlan == 'Team',
                    wide: true,
                    onPressed: () => _choosePlan('Team'),
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.detail,
    required this.current,
    required this.onPressed,
    this.wide = false,
  });

  final String title;
  final String price;
  final String detail;
  final bool current;
  final VoidCallback onPressed;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: current
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface))),
              Icon(
                current ? Icons.check_circle : Icons.circle_outlined,
                color: current
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
          Text('per month', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 14),
          Text(detail, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
            child: Text(current ? 'Current Plan' : 'Choose Plan'),
          ),
        ],
      ),
    );
  }
}
