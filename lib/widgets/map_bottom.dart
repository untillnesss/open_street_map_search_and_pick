
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/models/picked_data.dart';
import 'package:open_street_map_search_and_pick/widgets/wide_button.dart';

class MapBottom extends StatefulWidget {
  final MapController mapController;
  final bool isLoadingAddress;
  final String buttonText, focusingLocation;
  final Future<LatLng> Function(BuildContext context)? onCurrentLocationTap;
  final LatLng center;
  final Function(BuildContext, Future<PickedData> Function())? onPicked;
  final Function onTapFab;
  final Future<PickedData> Function() pickData;

  const MapBottom({
    Key? key,
    required this.mapController,
    required this.isLoadingAddress,
    required this.buttonText,
    required this.focusingLocation,
    this.onCurrentLocationTap,
    required this.center,
    this.onPicked,
    required this.onTapFab,
    required this.pickData,
  }) : super(key: key);

  @override
  State<MapBottom> createState() => _MapBottomState();
}

class _MapBottomState extends State<MapBottom> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'btn3',
                onPressed: () async {
                  LatLng result =
                      await widget.onCurrentLocationTap?.call(context) ??
                          widget.center;

                  this.widget.mapController.move(
                        result,
                        this.widget.mapController.camera.zoom,
                      );

                  this.widget.onTapFab.call();
                },
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 16),
              Card(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IgnorePointer(
                        child: StatefulBuilder(builder: (context, setState) {
                          return Text(
                            this.widget.focusingLocation,
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Visibility(
                        visible: this.widget.isLoadingAddress,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: const LinearProgressIndicator(),
                        ),
                      ),
                      WideButton(
                        this.widget.buttonText,
                        onPressed: () async {
                          widget.onPicked?.call(context, this.widget.pickData);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
