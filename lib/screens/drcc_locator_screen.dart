import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DrccLocatorScreen extends StatefulWidget {
  const DrccLocatorScreen({super.key});

  @override
  State<DrccLocatorScreen> createState() => _DrccLocatorScreenState();
}

class _DrccLocatorScreenState extends State<DrccLocatorScreen> {
  // Center of Bihar approximately
  final LatLng _biharCenter = const LatLng(25.9644, 85.2722);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _filteredLocations = [];

  final List<Map<String, dynamic>> _drccLocations = [
    {
      'name': 'DRCC Patna',
      'address': 'Chhajju Bagh, Patna, Bihar 800001',
      'location': const LatLng(25.6111, 85.1378),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Gaya',
      'address': 'Collectorate Campus, Gaya, Bihar 823001',
      'location': const LatLng(24.7955, 85.0002),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Muzaffarpur',
      'address': 'Company Bagh Rd, Muzaffarpur, Bihar 842001',
      'location': const LatLng(26.1209, 85.3647),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Bhagalpur',
      'address': 'Adampur, Bhagalpur, Bihar 812001',
      'location': const LatLng(25.2425, 86.9842),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Darbhanga',
      'address': 'Laheriasarai, Darbhanga, Bihar 846001',
      'location': const LatLng(26.1542, 85.8918),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Purnia',
      'address': 'Lining Club Road, Purnia, Bihar 854301',
      'location': const LatLng(25.7771, 87.4753),
      'phone': '1800 3456 444',
    },
    // Adding a few more for better search variety
    {
      'name': 'DRCC Saran (Chapra)',
      'address': 'Collectorate Campus, Chapra, Bihar 841301',
      'location': const LatLng(25.7831, 84.7303),
      'phone': '1800 3456 444',
    },
    {
      'name': 'DRCC Rohtas (Sasaram)',
      'address': 'Fazalganj, Sasaram, Bihar 821115',
      'location': const LatLng(24.9490, 84.0315),
      'phone': '1800 3456 444',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredLocations = List.from(_drccLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = List.from(_drccLocations);
      } else {
        _filteredLocations = _drccLocations.where((drcc) {
          final searchLower = query.toLowerCase();
          return drcc['name'].toString().toLowerCase().contains(searchLower) || 
                 drcc['address'].toString().toLowerCase().contains(searchLower);
        }).toList();
      }

      if (_filteredLocations.isNotEmpty && query.isNotEmpty) {
        _mapController.move(_filteredLocations.first['location'], 8.5);
      } else if (query.isEmpty) {
        _mapController.move(_biharCenter, 7.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Find My DRCC', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () {
              _mapController.move(_biharCenter, 7.0);
            },
            tooltip: 'Center Map',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _biharCenter,
              initialZoom: 7.0,
              interactionOptions: const InteractionOptions(
                 flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.bihar_scc_app',
            // Added a subtle color filter to match the premium theme slightly better than raw OSM
            tileBuilder: _darkModeTileBuilder,
          ),
          MarkerLayer(
            markers: _filteredLocations.map((drcc) {
              return Marker(
                point: drcc['location'],
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _showDrccDetails(context, drcc),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF6C00),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
                          ],
                        ),
                        child: Text(
                          drcc['name'].toString().replaceAll('DRCC ', ''),
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF0D1D14)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      Positioned(
        top: 24,
        left: 20,
        right: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterLocations,
            decoration: InputDecoration(
              hintText: 'Search District (e.g., Patna, Gaya)',
              hintStyle: GoogleFonts.outfit(color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF004B23)),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () {
                        _searchController.clear();
                        _filterLocations('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  // A subtle tint to make the open street map less jarring
  Widget _darkModeTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.9, 0, 0, 0, 15,
        0, 0.95, 0, 0, 20,
        0, 0, 0.9, 0, 15,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }

  void _showDrccDetails(BuildContext context, Map<String, dynamic> drcc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Color(0xFFEF6C00), size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drcc['name'],
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'District Registration & Counseling Center',
                        style: GoogleFonts.outfit(color: const Color(0xFFEF6C00), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.black38, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    drcc['address'],
                    style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_in_talk_rounded, color: Colors.black38, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    drcc['phone'],
                    style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchTurnByTurn(drcc['location'], 'google'),
                    icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                    label: Text('Google Maps', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2), // Google Blue variant
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchTurnByTurn(drcc['location'], 'apple'),
                    icon: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
                    label: Text('Apple Maps', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1D14), // Premium Dark
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchTurnByTurn(LatLng location, String mapType) async {
    Uri url;
    if (mapType == 'google') {
      url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}');
    } else {
      url = Uri.parse('http://maps.apple.com/?daddr=${location.latitude},${location.longitude}');
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps application.', style: GoogleFonts.outfit()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
