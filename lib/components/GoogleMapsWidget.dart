import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class GoogleMapsWidget extends StatefulWidget {

  final double height;
  const GoogleMapsWidget({super.key, required this.height});

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {

  late GoogleMapController  mapController;

  final LatLng _center= const LatLng(13.3243229, 74.7438821);

  void _onMapCreated(GoogleMapController controller){
    mapController= controller;
  }
  @override
  Widget build(BuildContext context) {
    return Container(

      height: widget.height,
      child: ClipRRect(

        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0
          ),
        ),
      ),
    );
  }
}
