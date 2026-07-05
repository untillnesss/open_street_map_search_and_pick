import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:open_street_map_search_and_pick/models/picked_data.dart';
import 'package:open_street_map_search_and_pick/widgets/map_bottom.dart';
import 'package:open_street_map_search_and_pick/widgets/map_pin.dart';
import 'package:open_street_map_search_and_pick/widgets/map_search.dart';
import 'package:open_street_map_search_and_pick/widgets/map_view.dart';
export 'models/picked_data.dart';

class OpenStreetMapSearchAndPick extends StatefulWidget {
  final LatLng center;
  // final void Function(PickedData pickedData) onPicked;
  final String buttonText;
  final Future<LatLng> Function(BuildContext context)? onCurrentLocationTap;
  final Function(BuildContext, Future<PickedData> Function())? onPicked;

  const OpenStreetMapSearchAndPick({
    Key? key,
    required this.center,
    required this.onPicked,
    this.buttonText = 'Set Current Location',
    this.onCurrentLocationTap,
  }) : super(key: key);

  @override
  State<OpenStreetMapSearchAndPick> createState() =>
      _OpenStreetMapSearchAndPickState();
}

class _OpenStreetMapSearchAndPickState
    extends State<OpenStreetMapSearchAndPick> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  String focusingLocation = '';
  bool isLoadingAddress = true;
  http.Client client = http.Client();

  void setNameCurrentPos() async {
    double latitude = mapController.camera.center.latitude;
    double longitude = mapController.camera.center.longitude;
    if (kDebugMode) {
      print(latitude);
    }
    if (kDebugMode) {
      print(longitude);
    }
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

    // searchController.text =
    //     decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
    focusingLocation =
        decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
    setState(() {});
  }

  void setNameCurrentPosAtInit() async {
    isLoadingAddress = true;
    setState(() {});

    double latitude = widget.center.latitude;
    double longitude = widget.center.longitude;
    if (kDebugMode) {
      print(latitude);
    }
    if (kDebugMode) {
      print(longitude);
    }
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;

    // searchController.text =
    //     decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";
    focusingLocation =
        decodedResponse['display_name'] ?? "MOVE TO CURRENT POSITION";

    isLoadingAddress = false;
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((time) {
      setNameCurrentPosAtInit();
    });

    mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        isLoadingAddress = true;
        setState(() {});
        var client = http.Client();
        String url =
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=${event.camera.center.latitude}&lon=${event.camera.center.longitude}&zoom=18&addressdetails=1';

        var response = await client.get(Uri.parse(url));
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<dynamic, dynamic>;
        debugPrint(decodedResponse.toString());
        // searchController.text = decodedResponse['display_name'] ?? '';
        focusingLocation = decodedResponse['display_name'] ?? '';
        isLoadingAddress = false;
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String? _autocompleteSelection;

    return GestureDetector(
      onTap: () {
        primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Stack(
          children: [
            MapView(
              widget: widget,
              mapController: mapController,
            ),
            MapPin(),
            MapSearch(
              mapController: this.mapController,
              searchController: this.searchController,
              onTapList: () {
                this.setNameCurrentPos();
              },
            ),
            KeyboardVisibilityBuilder(
              builder: (p0, isKeyboardVisible) {
                if (isKeyboardVisible) {
                  return Positioned.fill(child: SizedBox.shrink());
                }
                return MapBottom(
                  mapController: this.mapController,
                  buttonText: this.widget.buttonText,
                  center: this.widget.center,
                  focusingLocation: this.focusingLocation,
                  isLoadingAddress: this.isLoadingAddress,
                  onTapFab: () {
                    this.setNameCurrentPos();
                  },
                  onCurrentLocationTap: this.widget.onCurrentLocationTap,
                  onPicked: this.widget.onPicked,
                  pickData: this.pickData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<PickedData> pickData() async {
    LatLng center = LatLng(mapController.camera.center.latitude,
        mapController.camera.center.longitude);
    var client = http.Client();
    String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${mapController.camera.center.latitude}&lon=${mapController.camera.center.longitude}&zoom=18&addressdetails=1';

    var response = await client.get(Uri.parse(url));
    var decodedResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<dynamic, dynamic>;
    String displayName = decodedResponse['display_name'];
    return PickedData(center, displayName);
  }
}
