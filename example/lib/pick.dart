import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class PickView extends StatelessWidget {
  const PickView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Pick Map'),
      ),
      body: OpenStreetMapSearchAndPick(
        center: LatLng(23, 89),
        buttonColor: Colors.blue,
        buttonText: 'Set Current Location',
        onCurrentLocationTap: (context) async {
          return LatLng(-7.2363011, 112.7509539);
        },
        onPicked: (context, center, doPick) async {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );

          PickedData pickedData = await doPick(center);

          Navigator.pop(context);

          if (kDebugMode) {
            print(pickedData.latLong.latitude);
            print(pickedData.latLong.longitude);
            print(pickedData.address);
          }
        },
      ),
    );
  }
}
