import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {

  final int memberMisId;
  final String memberName;
  final double latitude;
  final double longitude;

  const MapScreen({super.key, 
    required this.memberMisId,
    required this.memberName,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  BitmapDescriptor? _pinDropIcon;

  @override
  void initState() {
    super.initState();
    // _loadCustomMarker();
    _getUserLocation();
    _fetchLocationsFromMySQL();
  }

  /// Load a custom "pin drop" marker
  void _loadCustomMarker() async {
    _pinDropIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)), 
      'assets/pin_drop.png', // Make sure to add this image in assets
    );
  }

  /// Get the user's current location
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng newLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentLocation = newLocation;
      _moveCameraToPosition(newLocation);
    });
  }

  /// Fetch members' locations and add them as markers
  Future<void> _fetchLocationsFromMySQL() async {

    setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId(widget.memberMisId.toString()),
            position: LatLng(widget.latitude, widget.longitude),
            icon: BitmapDescriptor.defaultMarker, // Use pin drop or default marker
            infoWindow: InfoWindow(
              title: widget.memberName,
              snippet: "Tap for Directions",
              onTap: () => _openGoogleMaps(widget.latitude, widget.longitude),
            ),
          ),
        );
    });
  }

  /// Move the camera to a given position smoothly
  void _moveCameraToPosition(LatLng position) {
    _controller?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 14.0),
    ));
  }

  /// Open Google Maps for directions
  void _openGoogleMaps(double lat, double lng) async {
    String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OD Monitoring')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _controller = controller;
                _moveCameraToPosition(_currentLocation!);
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationEnabled: true, // Shows blue dot like Google Maps
              myLocationButtonEnabled: true,
            ),
    );
  }
}
