// lib/screens/driver/share_location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({Key? key}) : super(key: key);

  @override
  _ShareLocationScreenState createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _location.onLocationChanged.listen((LocationData locationData) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );

      // Here, you would share the location with Firestore
      _shareLocation(locationData);
    });
  }

  void _shareLocation(LocationData locationData) {
    // Code to share the driver's location to Firestore
    // Use Firebase Firestore to update the driver's location in real-time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Location'),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.4219999, -122.0840575),
          zoom: 15,
        ),
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
