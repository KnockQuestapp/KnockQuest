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
      backgroundColor: Colors.white,
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
                      const Expanded(
                        child: Text('Subscription & Themes', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Manage your KnockQuest experience', style: TextStyle(color: Color(0xFF8B99AB))),
                  const SizedBox(height: 24),
                  const Text('Select a Plan', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
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
        border: Border.all(
          color: current ? const Color(0xFFE0B84B) : const Color(0xFFE5EAF1),
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF233655)))),
              Icon(
                current ? Icons.check_circle : Icons.circle_outlined,
                color: current ? const Color(0xFFE0B84B) : const Color(0xFF8B99AB),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
          const Text('per month', style: TextStyle(color: Color(0xFF8B99AB), fontSize: 12)),
          const SizedBox(height: 14),
          Text(detail, style: const TextStyle(color: Color(0xFF7E8CA0), fontSize: 12)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D5BD7), foregroundColor: Colors.white),
            child: Text(current ? 'Current Plan' : 'Choose Plan'),
          ),
        ],
      ),
    );
  }
}
