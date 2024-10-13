import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/widgets/o_s_mdata.dart';
import 'package:http/http.dart' as http;

class MapSearch extends StatefulWidget {
  final MapController mapController;
  final TextEditingController searchController;
  final Function onTapList;
  const MapSearch({
    Key? key,
    required this.mapController,
    required this.searchController,
    required this.onTapList,
  }) : super(key: key);

  @override
  State<MapSearch> createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  final FocusNode focusNode = FocusNode();
  List<OSMdata> options = <OSMdata>[];
  Timer? debounce;
  bool isLoading = false;

  double get getHeightContainer {
    if (!this.focusNode.hasFocus) return 0;
    return MediaQuery.of(context).size.height / 3;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              TextFormField(
                controller: this.widget.searchController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search Location',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  suffixIcon: IconButton(
                    onPressed: () {
                      this.widget.searchController.clear();

                      setState(() {});
                    },
                    icon: Icon(Icons.close),
                  ),
                ),
                onChanged: (String value) {
                  this.isLoading = true;
                  setState(() {});
                  if (debounce?.isActive ?? false) debounce?.cancel();
                  http.Client client = http.Client();

                  debounce =
                      Timer(const Duration(milliseconds: 1000), () async {
                    if (kDebugMode) {
                      print(value);
                    }
                    try {
                      String url =
                          'https://nominatim.openstreetmap.org/search?q=$value&format=json&polygon_geojson=1&addressdetails=1';
                      if (kDebugMode) {
                        print(url);
                      }
                      var response = await client.get(Uri.parse(url));
                      var decodedResponse =
                          jsonDecode(utf8.decode(response.bodyBytes))
                              as List<dynamic>;
                      if (kDebugMode) {
                        print(decodedResponse);
                      }
                      options = decodedResponse
                          .map((e) => OSMdata(
                              displayname: e['display_name'],
                              lat: double.parse(e['lat']),
                              lon: double.parse(e['lon'])))
                          .toList();
                      setState(() {});
                    } finally {
                      client.close();
                      this.isLoading = false;
                    }

                    setState(() {});
                  });
                },
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    height: this.getHeightContainer,
                    child: Builder(builder: (context) {
                      if (this.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (options.isEmpty &&
                          this.widget.searchController.text != '') {
                        return Center(
                          child: Text('No data found'),
                        );
                      }
                      if (this.widget.searchController.text == '') {
                        return Center(
                          child: Text('Start typing...'),
                        );
                      }
                      return ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(options[index].displayname),
                            subtitle: Text(
                                '${options[index].lat},${options[index].lon}'),
                            onTap: () {
                              this.widget.mapController.move(
                                  LatLng(
                                      options[index].lat, options[index].lon),
                                  15.0);

                              this.widget.onTapList.call();
                              focusNode.unfocus();
                              options.clear();
                              setState(() {});
                            },
                          );
                        },
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
