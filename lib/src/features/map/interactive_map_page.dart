import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  final _searchController = TextEditingController();
  int _selectedRangeIndex = 1;
  int _selectedDrawTool = 0;

  static const _ranges = ['100m', '250m', '500m', '1km'];

  String get _searchText => _searchController.text.trim();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectRange(int index) {
    setState(() {
      _selectedRangeIndex = index;
    });
  }

  void _selectDrawTool(int index) {
    setState(() {
      _selectedDrawTool = index;
    });
    final label = 'Draw tool ${index + 1} selected';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
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
                  options: const MapOptions(
                    initialCenter: LatLng(40.7128, -74.0060),
                    initialZoom: 12.8,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.knockquest.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(40.7128, -74.0060),
                          width: 30,
                          height: 30,
                          child: Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary, size: 30),
                        ),
                      ],
                    ),
                  ],
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
