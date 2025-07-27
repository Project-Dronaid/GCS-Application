import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsWidget extends StatefulWidget {
  final double height;
  final Map<dynamic, dynamic> data;

  GoogleMapsWidget({Key? key, required this.height, this.data = const {}})
      : super(key: key);

  @override
  State<GoogleMapsWidget> createState() => _GoogleMapsWidgetState();
}

class _GoogleMapsWidgetState extends State<GoogleMapsWidget> {
  static const platform = MethodChannel('com.example.gcs_application/channel');

  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(13.3243229, 74.7438821);
  Marker? _droneMarker;
  BitmapDescriptor? _droneIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();

    platform.setMethodCallHandler((call) async {
      if (call.method == 'updateTelemetry') {
        final newData = Map<String, dynamic>.from(call.arguments);
        final lat = newData["latitude"] ?? _initialPosition.latitude;
        final lon = newData["longitude"] ?? _initialPosition.longitude;
        _updateDroneMarker(LatLng(lat, lon));
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _loadCustomMarker() async {
    _droneIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/drone.png',
    );
    setState(() {});
  }

  void _updateDroneMarker(LatLng position) {
    final marker = Marker(
      markerId: const MarkerId('drone'),
      position: position,
      icon: _droneIcon ?? BitmapDescriptor.defaultMarker,
      rotation: 0,
      anchor: const Offset(0.5, 0.5),
    );

    setState(() {
      _droneMarker = marker;
    });
    print(_mapController.toString());
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          markers: _droneMarker != null ? {_droneMarker!} : {},
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _initialPosition,
            zoom: 15.0,
          ),
        ),
      ),
    );
  }
}
