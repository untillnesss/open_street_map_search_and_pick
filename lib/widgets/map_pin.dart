import 'package:flutter/material.dart';

class MapPin extends StatelessWidget {
  const MapPin({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Icon(
            Icons.location_pin,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
