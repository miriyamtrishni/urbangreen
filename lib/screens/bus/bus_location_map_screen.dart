// lib/screens/bus/bus_location_map_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart'; // For accessing user location
import 'package:url_launcher/url_launcher.dart'; // To dial emergency number
import 'package:geolocator/geolocator.dart'; // For calculating distance between locations
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart'; // Assuming you have a constants file for colors
import 'bus_stops_screen.dart'; // Import the BusStopsScreen

class BusLocationMapScreen extends StatefulWidget {
  final String busId;
  final String licensePlate;

  const BusLocationMapScreen({
    Key? key,
    required this.busId,
    required this.licensePlate,
  }) : super(key: key);

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

  // Route Information
  String? routeNumber;
  String? beginning;
  String? destination;
  List<dynamic> busStops = []; // List to hold bus stops

  @override
  void initState() {
    super.initState();
    _fetchBusLocation();
    _fetchUserLocation();
    _fetchRouteInformation(); // Fetch route information on initialization
  }

  /// Fetches the real-time location of the bus from Firestore
  Future<void> _fetchBusLocation() async {
    FirebaseFirestore.instance
        .collection('driver_locations')
        .doc(widget.busId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setState(() {
          busLocation = LatLng(doc['latitude'], doc['longitude']);
          _calculateDistance();
        });
      }
    });
  }

  /// Fetches the user's current location with permission handling
  Future<void> _fetchUserLocation() async {
    try {
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      // Check if location services are enabled
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          // User denied location services
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
          return;
        }
      }

      // Check location permissions
      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          // User denied location permissions
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      // Get the user's current location
      LocationData locationData = await location.getLocation();
      setState(() {
        userLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _calculateDistance();
      });
    } catch (e) {
      print('Error fetching user location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching user location.')),
      );
    }
  }

  /// Fetches route information including bus stops from Firestore
  Future<void> _fetchRouteInformation() async {
    try {
      // Fetch the bus document based on busId
      var busDoc = await FirebaseFirestore.instance
          .collection('driver_buses')
          .doc(widget.busId)
          .get();

      if (busDoc.exists) {
        var routeNum = busDoc['route'];
        print('Bus route: $routeNum'); // Debugging: Print the route number

        // Attempt to fetch the route document assuming routeNum is the document ID
        var routeDoc = await FirebaseFirestore.instance
            .collection('bus_routes')
            .doc(routeNum)
            .get();

        if (routeDoc.exists) {
          setState(() {
            routeNumber = routeDoc['routeNumber'];
            beginning = routeDoc['beginning'];
            destination = routeDoc['destination'];
            busStops = List<dynamic>.from(routeDoc['busStops'] ?? []);
          });
          print(
              'Route info (Doc ID): $routeNumber, $beginning, $destination, Stops: $busStops'); // Debugging
          return;
        }

        // If routeNum is not the document ID, query by 'routeNumber' field
        var routeSnapshot = await FirebaseFirestore.instance
            .collection('bus_routes')
            .where('routeNumber', isEqualTo: routeNum)
            .limit(1)
            .get();

        if (routeSnapshot.docs.isNotEmpty) {
          var routeDoc = routeSnapshot.docs.first;
          setState(() {
            routeNumber = routeDoc['routeNumber'];
            beginning = routeDoc['beginning'];
            destination = routeDoc['destination'];
            busStops = List<dynamic>.from(routeDoc['busStops'] ?? []);
          });
          print(
              'Route info (Field Query): $routeNumber, $beginning, $destination, Stops: $busStops'); // Debugging
        } else {
          print('Route document not found'); // Debugging: Route not found in Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route information not found.')),
          );
        }
      } else {
        print('Bus document not found'); // Debugging: Bus document not found in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus information not found.')),
        );
      }
    } catch (e) {
      print('Error fetching route information: $e'); // Debugging: Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching route information.')),
      );
    }
  }

  /// Calculates the distance between the user's location and the bus location
  Future<void> _calculateDistance() async {
    if (userLocation != null && busLocation != null) {
      distanceToBus = Geolocator.distanceBetween(
            userLocation!.latitude,
            userLocation!.longitude,
            busLocation!.latitude,
            busLocation!.longitude,
          ) /
          1000; // Convert to kilometers
      setState(() {});
    }
  }

  /// Handles bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation is handled within CustomNavBar
  }

  /// Launches the phone dialer with the emergency number 911
  Future<void> _dialEmergency() async {
    const emergencyNumber = 'tel:911';
    if (await canLaunch(emergencyNumber)) {
      await launch(emergencyNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch emergency dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Bus Location',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_bus, color: Colors.black),
            onPressed: () {
              if (routeNumber != null && busStops.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusStopsScreen(
                      routeNumber: routeNumber!,
                      busStops: busStops,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Bus stops are not available for this route.')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Display Google Map or a loading indicator
          busLocation == null || userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: userLocation!,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('bus'),
                      position: busLocation!,
                      infoWindow:
                          const InfoWindow(title: 'Current Bus Location'),
                    ),
                    Marker(
                      markerId: const MarkerId('user'),
                      position: userLocation!,
                      infoWindow: const InfoWindow(title: 'Your Location'),
                      icon:
                          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                  polylines: busLocation != null && userLocation != null
                      ? {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: [userLocation!, busLocation!],
                            color: AppColors.primaryColor,
                            width: 5,
                          ),
                        }
                      : {},
                ),

          // Card displaying route information
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  routeNumber != null &&
                          beginning != null &&
                          destination != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Route: $routeNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '$beginning - $destination',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const Text(
                          'Loading route information...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ],
              ),
            ),
          ),

          // Emergency Icon on the map (Clickable to dial 911)
          Positioned(
            right: 10,
            bottom: 150, // Adjusted position to avoid overlapping with distance info
            child: GestureDetector(
              onTap: _dialEmergency,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.warning, color: Colors.red, size: 30),
              ),
            ),
          ),

          // Distance Information Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    distanceToBus != null
                        ? 'Distance to Bus: ${distanceToBus!.toStringAsFixed(2)} km'
                        : 'Calculating distance...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  routeNumber != null &&
                          beginning != null &&
                          destination != null
                      ? Text(
                          'Route: $routeNumber\n$beginning ➔ $destination',
                          style: const TextStyle(fontSize: 14),
                        )
                      : Container(),
                ],
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
