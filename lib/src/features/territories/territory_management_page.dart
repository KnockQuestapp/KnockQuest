import 'package:flutter/material.dart';

import '../../sample_data.dart';

class TerritoryManagementPage extends StatefulWidget {
  const TerritoryManagementPage({super.key});

  @override
  State<TerritoryManagementPage> createState() => _TerritoryManagementPageState();
}

class _TerritoryManagementPageState extends State<TerritoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _sortByGci = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TerritoryRecord> get _filteredTerritories {
    final query = _searchController.text.trim().toLowerCase();
    final items = territories
        .where((t) => t.name.toLowerCase().contains(query))
        .toList();

    if (_sortByGci) {
      items.sort((a, b) => b.gci.compareTo(a.gci));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final displayedTerritories = _filteredTerritories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Territories',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Manage and track field performance',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                        child: Icon(Icons.add_location_alt_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search territories...',
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color, size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() => _sortByGci = !_sortByGci),
                        borderRadius: BorderRadius.circular(19),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), shape: BoxShape.circle),
                          child: Icon(
                            _sortByGci ? Icons.tune : Icons.sort,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Boundary editor opened.')),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(18)),
                      child: Row(
                      children: [
                        CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary, child: Icon(Icons.draw_outlined, color: Theme.of(context).colorScheme.onSecondary)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Draw New Boundary',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Define custom areas on the map',
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 217), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onPrimary),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                    'Active Territories',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                      const Spacer(),
                      Text(
                        _sortByGci ? 'Sort by GCI' : 'Sort by Name',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: displayedTerritories.isEmpty
                        ? Center(
                            child: Text(
                              'No territories match your search.',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayedTerritories.length,
                            itemBuilder: (context, index) {
                              final territory = displayedTerritories[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(18)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(width: 14, height: 14, color: Theme.of(context).colorScheme.primary),
                                          const Spacer(),
                                          Text(
                                            territory.change,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        territory.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            territory.gci,
                                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                                          ),
                                          const Spacer(),
                                          Text(
                                            territory.leads,
                                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'View Map',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
