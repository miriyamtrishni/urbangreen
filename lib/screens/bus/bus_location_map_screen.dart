// lib/screens/bus/bus_location_map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart'; // For accessing user location
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart';
import 'package:geolocator/geolocator.dart'; // For calculating distance between locations

class BusLocationMapScreen extends StatefulWidget {
  final String busId;
  final String licensePlate;

  const BusLocationMapScreen({Key? key, required this.busId, required this.licensePlate}) : super(key: key);

  @override
  _BusLocationMapScreenState createState() => _BusLocationMapScreenState();
}

class _BusLocationMapScreenState extends State<BusLocationMapScreen> {
  // ignore: unused_field
  GoogleMapController? _mapController;
  LatLng? busLocation;
  LatLng? userLocation;
  double? distanceToBus; // Distance between the user and the bus
  Location location = Location(); // For accessing user location
  int _selectedIndex = 2; // Set Bus as initially selected

  @override
  void initState() {
    super.initState();
    _fetchBusLocation();
    _fetchUserLocation();
  }

  Future<void> _fetchBusLocation() async {
    // Fetch the bus location in real-time from Firestore
    FirebaseFirestore.instance.collection('driver_locations').doc(widget.busId).snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          busLocation = LatLng(doc['latitude'], doc['longitude']);
          _calculateDistance();
        });
      }
    });
  }

  Future<void> _fetchUserLocation() async {
    // Get the user's current location
    LocationData locationData = await location.getLocation();
    setState(() {
      userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _calculateDistance();
    });
  }

  Future<void> _calculateDistance() async {
    if (userLocation != null && busLocation != null) {
      // Calculate the distance between the user's location and the bus location
      distanceToBus = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        busLocation!.latitude,
        busLocation!.longitude,
      ) / 1000; // Convert to kilometers
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation is handled within CustomNavBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Location: ${widget.licensePlate}'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          busLocation == null || userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: userLocation!, zoom: 14.0),
                  markers: {
                    Marker(
                      markerId: const MarkerId('bus'),
                      position: busLocation!,
                      infoWindow: const InfoWindow(title: 'Current Bus Location'),
                    ),
                    Marker(
                      markerId: const MarkerId('user'),
                      position: userLocation!,
                      infoWindow: const InfoWindow(title: 'Your Location'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                  polylines: busLocation != null && userLocation != null
                      ? {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: [userLocation!, busLocation!],
                            color: Colors.green,
                            width: 5,
                          ),
                        }
                      : {},
                ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  distanceToBus != null
                      ? 'Distance to Bus: ${distanceToBus!.toStringAsFixed(2)} km'
                      : 'Calculating distance...',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
