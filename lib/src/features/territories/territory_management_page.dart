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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Territories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                            SizedBox(height: 6),
                            Text('Manage and track field performance', style: TextStyle(color: Color(0xFF8B99AB))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(color: Color(0xFF1D5BD7), shape: BoxShape.circle),
                        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white, size: 20),
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
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF8B99AB), size: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFD9E1EC)),
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
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD9E1EC)), shape: BoxShape.circle),
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
                      decoration: BoxDecoration(color: const Color(0xFF1D5BD7), borderRadius: BorderRadius.circular(18)),
                      child: const Row(
                      children: [
                        CircleAvatar(backgroundColor: Color(0xFF2B6BE3), child: Icon(Icons.draw_outlined, color: Colors.white)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Draw New Boundary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text('Define custom areas on the map', style: TextStyle(color: Color(0xFFDDE8FF), fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text('Active Territories', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF506178))),
                      const Spacer(),
                      Text(
                        _sortByGci ? 'Sort by GCI' : 'Sort by Name',
                        style: const TextStyle(color: Color(0xFF1D5BD7), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: displayedTerritories.isEmpty
                        ? const Center(
                            child: Text(
                              'No territories match your search.',
                              style: TextStyle(color: Color(0xFF8B99AB)),
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
                                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5EAF1)), borderRadius: BorderRadius.circular(18)),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(width: 14, height: 14, color: const Color(0xFF1D5BD7)),
                                          const Spacer(),
                                          Text(territory.change, style: const TextStyle(color: Color(0xFF35C784), fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(territory.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF233655))),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(territory.gci, style: const TextStyle(color: Color(0xFF506178))),
                                          const Spacer(),
                                          Text(territory.leads, style: const TextStyle(color: Color(0xFF8B99AB))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('View Map', style: TextStyle(color: Color(0xFF1D5BD7), fontWeight: FontWeight.w600)),
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
