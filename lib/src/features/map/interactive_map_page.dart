import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/territory_service.dart';
import '../../services/lead_service.dart';

class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  final _searchController = TextEditingController();
  final TerritoryService _territoryService = TerritoryService();
  final LeadService _leadService = LeadService();
  
  int _selectedRangeIndex = 1;
  bool _isDrawing = false;
  List<LatLng> _currentPolygon = [];
  List<List<LatLng>> _territories = [];
  List<Map<String, dynamic>> _leads = [];
  bool _isLoading = true;
  String? _territoryName;
  bool _isSavingTerritory = false;

  static const _ranges = ['100m', '250m', '500m', '1km'];
  final MapController _mapController = MapController();

  String get _searchText => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final territories = await _territoryService.getTerritories();
      final leads = await _leadService.getLeads();
      setState(() {
        _territories = territories.map((t) => _parsePolygon(t['polygon'])).toList();
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  List<LatLng> _parsePolygon(String? polygonWKT) {
    if (polygonWKT == null) return [];
    try {
      // Simple parser for POLYGON((lng lat, lng lat, ...))
      final coords = polygonWKT
          .replaceAll('POLYGON((', '')
          .replaceAll('))', '')
          .split(',');
      return coords.map((c) {
        final parts = c.trim().split(' ');
        return LatLng(double.parse(parts[1]), double.parse(parts[0]));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  void _toggleDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (!_isDrawing) {
        _currentPolygon = [];
        _territoryName = null;
      }
    });
  }

  void _addPointToPolygon(LatLng point) {
    if (!_isDrawing) return;
    setState(() {
      _currentPolygon.add(point);
    });
  }

  Future<void> _saveTerritory() async {
    if (_currentPolygon.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw a polygon with at least 3 points')),
      );
      return;
    }
    
    final name = _territoryName?.trim() ?? 'Territory ${DateTime.now().day}/${DateTime.now().month}';
    setState(() => _isSavingTerritory = true);
    
    try {
      await _territoryService.createTerritory(
        name: name,
        description: 'Created on ${DateTime.now().toLocal().toString().split(' ')[0]}',
        polygon: _currentPolygon,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Territory saved successfully!')),
      );
      setState(() {
        _isDrawing = false;
        _currentPolygon = [];
        _territoryName = null;
        _isSavingTerritory = false;
      });
      await _loadData();
    } catch (e) {
      setState(() => _isSavingTerritory = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving territory: ${e.toString()}')),
      );
    }
  }

  void _selectRange(int index) {
    setState(() {
      _selectedRangeIndex = index;
    });
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Map Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected radius: ${_ranges[_selectedRangeIndex]}',
                ),
                if (_searchText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Search query: "$_searchText"'),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        );
      },
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
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(40.7128, -74.0060),
                    initialZoom: 12.8,
                    onTap: (tapPosition, point) {
                      if (_isDrawing) {
                        _addPointToPolygon(point);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.knockquest.app',
                    ),
                    // Show existing territories
                    if (!_isLoading && _territories.isNotEmpty)
                      ..._territories.map((polygon) => PolygonLayer(
                        polygons: [
                          Polygon(
                            points: polygon,
                            color: Colors.blue.withOpacity(0.3),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      )),
                    // Show current drawing polygon
                    if (_isDrawing && _currentPolygon.isNotEmpty)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: _currentPolygon,
                            color: Colors.green.withOpacity(0.4),
                            borderColor: Colors.green,
                            borderStrokeWidth: 3,
                          ),
                        ],
                      ),
                    // Show lead markers
                    MarkerLayer(
                      markers: _leads.map((lead) => Marker(
                        point: LatLng(
                          (lead['latitude'] ?? 40.7128).toDouble(),
                          (lead['longitude'] ?? -74.0060).toDouble(),
                        ),
                        width: 30,
                        height: 30,
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lead: ${lead['name']}')),
                            );
                          },
                          child: Icon(
                            Icons.location_pin,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search address or lead name',
                                prefixIcon: Icon(Icons.search, color: Theme.of(context).textTheme.bodySmall?.color),
                                suffixIcon: _searchText.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CircleIcon(icon: Icons.tune, onTap: _openFilters),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_searchText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Searching: $_searchText',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            for (var i = 0; i < _ranges.length; i++) ...[
                              _RangeChip(
                                _ranges[i],
                                selected: _selectedRangeIndex == i,
                                onTap: () => _selectRange(i),
                              ),
                              if (i != _ranges.length - 1) const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          children: [
                            _MapActionButton(
                              'draw',
                              selected: _selectedDrawTool == 0,
                              onTap: () => _selectDrawTool(0),
                            ),
                            const SizedBox(height: 10),
                            _MapActionButton(
                              'draw',
                              selected: _selectedDrawTool == 1,
                              onTap: () => _selectDrawTool(1),
                            ),
                            const SizedBox(height: 10),
                            _MapActionButton(
                              'draw',
                              selected: _selectedDrawTool == 2,
                              onTap: () => _selectDrawTool(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            final searchSuffix = _searchText.isEmpty
                                ? ''
                                : ' for "$_searchText"';
                            final message =
                                'Boundary saved (${_ranges[_selectedRangeIndex]})$searchSuffix';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(
              'Save Boundary',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip(
    this.label, {
    this.selected = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).textTheme.bodySmall?.color),
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton(
    this.label, {
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_location_alt_outlined, color: Theme.of(context).colorScheme.onPrimary, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
