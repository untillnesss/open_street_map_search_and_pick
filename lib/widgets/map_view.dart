import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MapView extends StatelessWidget {
  const MapView({
    Key? key,
    required this.widget,
    required MapController mapController,
  })  : _mapController = mapController,
        super(key: key);

  final OpenStreetMapSearchAndPick widget;
  final MapController _mapController;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(widget.center.latitude, widget.center.longitude),
          initialZoom: 15.0,
          maxZoom: 18,
          minZoom: 6,
        ),
        mapController: _mapController,
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
        ],
      ),
    );
  }
}
