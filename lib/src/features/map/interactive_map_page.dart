import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_routes.dart';
import '../../sample_data.dart';
import '../../state/auth_store.dart';
import '../../state/lead_store.dart';

class InteractiveMapPage extends StatefulWidget {
  const InteractiveMapPage({super.key});

  @override
  State<InteractiveMapPage> createState() => _InteractiveMapPageState();
}

class _InteractiveMapPageState extends State<InteractiveMapPage> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  int _selectedRangeIndex = 1;
  int _selectedDrawTool = 0;
  final List<LatLng> _draftPoints = [];
  List<_MapDrawing> _savedDrawings = [];
  Offset? _pointerDownPosition;
  DateTime? _pointerDownAt;
  Offset? _fallbackDownPosition;
  LatLng? _lastAddedPoint;
  DateTime? _lastAddedAt;

  static const _ranges = ['100m', '250m', '500m', '1km'];
  static const _radiusMeters = [100.0, 250.0, 500.0, 1000.0];

  String get _searchText => _searchController.text.trim();
  String get _drawingsKey =>
      'knockquest_map_drawings_${AuthStore.instance.currentUser.value?.id ?? 'guest'}';

  @override
  void initState() {
    super.initState();
    _loadDrawings();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrawings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_drawingsKey);
      if (raw == null || !mounted) return;
      final decoded = jsonDecode(raw) as List<dynamic>;
      setState(() {
        _savedDrawings = decoded
            .map((item) => _MapDrawing.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) _showMessage('Saved drawings could not be loaded.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addDrawPoint(LatLng point) {
    final now = DateTime.now();
    final previous = _lastAddedPoint;
    if (previous != null &&
        _lastAddedAt != null &&
        now.difference(_lastAddedAt!) < const Duration(milliseconds: 300) &&
        (point.latitude - previous.latitude).abs() < 0.00001 &&
        (point.longitude - previous.longitude).abs() < 0.00001) {
      return;
    }
    _lastAddedPoint = point;
    _lastAddedAt = now;
    setState(() {
      if (_selectedDrawTool == 0) {
        _draftPoints
          ..clear()
          ..add(point);
      } else {
        _draftPoints.add(point);
      }
    });
  }

  void _handleMapPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _pointerDownAt = DateTime.now();
  }

  void _handleMapPointerUp(PointerUpEvent event, LatLng point) {
    final start = _pointerDownPosition;
    final startedAt = _pointerDownAt;
    _pointerDownPosition = null;
    _pointerDownAt = null;
    if (start == null || startedAt == null) return;
    if ((event.position - start).distance <= 12 &&
        DateTime.now().difference(startedAt) < const Duration(seconds: 2)) {
      _addDrawPoint(point);
    }
  }

  Future<void> _saveDrawing() async {
    final minimumPoints = [1, 3, 2][_selectedDrawTool];
    if (_draftPoints.length < minimumPoints) {
      _showMessage(
        _selectedDrawTool == 0
            ? 'Tap the map to place a circle first.'
            : 'Tap the map at least $minimumPoints times to draw a ${_selectedDrawTool == 1 ? 'polygon' : 'route'}.',
      );
      return;
    }
    final drawing = _MapDrawing(
      tool: _selectedDrawTool,
      radiusMeters: _radiusMeters[_selectedRangeIndex],
      points: List.of(_draftPoints),
    );
    final updated = [..._savedDrawings, drawing];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _drawingsKey,
        jsonEncode(updated.map((item) => item.toJson()).toList()),
      );
      if (!mounted) return;
      setState(() {
        _savedDrawings = updated;
        _draftPoints.clear();
      });
      _showMessage('${['Circle', 'Polygon', 'Route'][drawing.tool]} saved.');
    } catch (_) {
      if (mounted) {
        _showMessage('Drawing could not be saved. Please try again.');
      }
    }
  }

  void _selectRange(int index) {
    setState(() {
      _selectedRangeIndex = index;
    });
  }

  void _selectDrawTool(int index) {
    setState(() {
      _selectedDrawTool = index;
      _draftPoints.clear();
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
                Text('Selected radius: ${_ranges[_selectedRangeIndex]}'),
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
            child: Listener(
              onPointerDown: (event) {
                _fallbackDownPosition = event.localPosition;
              },
              onPointerCancel: (_) => _fallbackDownPosition = null,
              onPointerUp: (event) {
                final start = _fallbackDownPosition;
                _fallbackDownPosition = null;
                if (start == null ||
                    (event.localPosition - start).distance > 12) {
                  return;
                }
                final position = event.localPosition;
                final size = _mapController.camera.size;
                // The controls are laid over the map. Only treat taps in the
                // unobstructed area as drawing input.
                if (position.dy < 160 ||
                    position.dy > size.height - 110 ||
                    (position.dx > size.width - 165 &&
                        position.dy > size.height - 380)) {
                  return;
                }
                _addDrawPoint(_mapController.camera.offsetToCrs(position));
              },
              child: Stack(
                children: [
                  ValueListenableBuilder<List<LeadRecord>>(
                    valueListenable: LeadStore.instance.leads,
                    builder: (context, leads, _) {
                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(40.7128, -74.0060),
                          initialZoom: 12.8,
                          onTap: (_, point) => _addDrawPoint(point),
                          onPointerDown: (event, _) =>
                              _handleMapPointerDown(event),
                          onPointerUp: _handleMapPointerUp,
                          onPointerCancel: (_, _) {
                            _pointerDownPosition = null;
                            _pointerDownAt = null;
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.knockquest.app',
                          ),
                          IgnorePointer(
                            child: CircleLayer(
                              circles: [
                                for (final drawing in _savedDrawings)
                                  if (drawing.tool == 0)
                                    CircleMarker(
                                      point: drawing.points.first,
                                      radius: drawing.radiusMeters,
                                      useRadiusInMeter: true,
                                      color: const Color(0x552565D6),
                                      borderColor: const Color(0xFF2565D6),
                                      borderStrokeWidth: 2,
                                    ),
                                if (_selectedDrawTool == 0 &&
                                    _draftPoints.isNotEmpty)
                                  CircleMarker(
                                    point: _draftPoints.first,
                                    radius: _radiusMeters[_selectedRangeIndex],
                                    useRadiusInMeter: true,
                                    color: const Color(0x7735C784),
                                    borderColor: const Color(0xFF159461),
                                    borderStrokeWidth: 3,
                                  ),
                              ],
                            ),
                          ),
                          IgnorePointer(
                            child: PolygonLayer(
                              polygons: [
                                for (final drawing in _savedDrawings)
                                  if (drawing.tool == 1)
                                    Polygon(
                                      points: drawing.points,
                                      color: const Color(0x552565D6),
                                      borderColor: const Color(0xFF2565D6),
                                      borderStrokeWidth: 3,
                                    ),
                                if (_selectedDrawTool == 1 &&
                                    _draftPoints.length >= 3)
                                  Polygon(
                                    points: _draftPoints,
                                    color: const Color(0x7735C784),
                                    borderColor: const Color(0xFF159461),
                                    borderStrokeWidth: 3,
                                  ),
                              ],
                            ),
                          ),
                          IgnorePointer(
                            child: PolylineLayer(
                              polylines: [
                                for (final drawing in _savedDrawings)
                                  if (drawing.tool == 2)
                                    Polyline(
                                      points: drawing.points,
                                      color: const Color(0xFF2565D6),
                                      strokeWidth: 4,
                                    ),
                                if (_selectedDrawTool != 0 &&
                                    _draftPoints.length >= 2)
                                  Polyline(
                                    points: _draftPoints,
                                    color: const Color(0xFF159461),
                                    strokeWidth: 4,
                                  ),
                              ],
                            ),
                          ),
                          IgnorePointer(
                            child: CircleLayer(
                              circles: [
                                for (final point in _draftPoints)
                                  CircleMarker(
                                    point: point,
                                    radius: 6,
                                    color: const Color(0xFF159461),
                                    borderColor: Colors.white,
                                    borderStrokeWidth: 2,
                                  ),
                              ],
                            ),
                          ),
                          MarkerLayer(
                            markers: leads.map((lead) {
                              return Marker(
                                point: LatLng(lead.latitude, lead.longitude),
                                width: 30,
                                height: 30,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.leadDetails,
                                  ),
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 30,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
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
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color,
                                  ),
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
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Searching: $_searchText',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
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
                                if (i != _ranges.length - 1)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              child: Text(
                                _selectedDrawTool == 0
                                    ? 'Circle: choose a radius, then tap the map${_draftPoints.isEmpty ? '' : ' (placed)'}.'
                                    : _selectedDrawTool == 1
                                    ? 'Polygon: tap at least 3 corners on the map (${_draftPoints.length} points).'
                                    : 'Route: tap at least 2 points on the map (${_draftPoints.length} points).',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: [
                              _MapActionButton(
                                'Circle',
                                selected: _selectedDrawTool == 0,
                                onTap: () => _selectDrawTool(0),
                              ),
                              const SizedBox(height: 10),
                              _MapActionButton(
                                'Polygon',
                                selected: _selectedDrawTool == 1,
                                onTap: () => _selectDrawTool(1),
                              ),
                              const SizedBox(height: 10),
                              _MapActionButton(
                                'Route',
                                selected: _selectedDrawTool == 2,
                                onTap: () => _selectDrawTool(2),
                              ),
                              const SizedBox(height: 10),
                              _MapActionButton(
                                'Add Lead',
                                selected: false,
                                onTap: () {
                                  final center = _mapController.camera.center;
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.addLead,
                                    arguments: {
                                      'latitude': center.latitude,
                                      'longitude': center.longitude,
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              if (_draftPoints.isNotEmpty) ...[
                                TextButton(
                                  onPressed: () =>
                                      setState(_draftPoints.removeLast),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF1F2937),
                                  ),
                                  child: const Text('Undo Point'),
                                ),
                                TextButton(
                                  onPressed: () => setState(_draftPoints.clear),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF1F2937),
                                  ),
                                  child: const Text('Clear Draft'),
                                ),
                              ],
                              ElevatedButton(
                                onPressed: _saveDrawing,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                child: Text(
                                  'Save Boundary',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ],
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
  const _RangeChip(this.label, {this.selected = false, required this.onTap});

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
          color: selected
              ? const Color(0xFF1D5BD7)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
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
    final foreground = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1D5BD7)
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_location_alt_outlined, color: foreground, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapDrawing {
  const _MapDrawing({
    required this.tool,
    required this.radiusMeters,
    required this.points,
  });

  final int tool;
  final double radiusMeters;
  final List<LatLng> points;

  Map<String, dynamic> toJson() => {
    'tool': tool,
    'radiusMeters': radiusMeters,
    'points': [
      for (final point in points) [point.latitude, point.longitude],
    ],
  };

  factory _MapDrawing.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as List<dynamic>)
        .map((value) => value as List<dynamic>)
        .map(
          (value) => LatLng(
            (value[0] as num).toDouble(),
            (value[1] as num).toDouble(),
          ),
        )
        .toList();
    final tool = json['tool'] as int;
    if (tool < 0 || tool > 2 || points.length < [1, 3, 2][tool]) {
      throw const FormatException('Invalid map drawing');
    }
    return _MapDrawing(
      tool: tool,
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      points: points,
    );
  }
}
