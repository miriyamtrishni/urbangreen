// lib/screens/driver/driver_home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart'; // Location package for real-time location updates
import '../authentication/login_screen.dart'; // Login screen
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps package

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  String? busLicensePlate;
  bool hasAddedBus = false;
  String? selectedRoute;
  final TextEditingController _licensePlateController = TextEditingController();
  Location location = Location(); // For accessing current location
  bool isSharingLocation = false; // To track if the driver is sharing the location
  late StreamSubscription<LocationData> _locationSubscription;

  // Google Maps controller
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(0, 0); // Default location, updated in real time

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _checkIfBusAdded();
  }

  Future<void> _checkIfBusAdded() async {
    // Check if the driver has already added their bus
    if (currentUser != null) {
      DocumentSnapshot busDoc = await FirebaseFirestore.instance
          .collection('driver_buses')
          .doc(currentUser!.uid)
          .get();

      if (busDoc.exists) {
        setState(() {
          busLicensePlate = busDoc['licensePlate'];
          hasAddedBus = true;
        });
      }
    }
  }

  Future<void> _addBus() async {
    if (selectedRoute == null || _licensePlateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a route and add a license plate number')),
      );
      return;
    }

    try {
      // Save the bus details to Firestore under the driver's UID
      await FirebaseFirestore.instance.collection('driver_buses').doc(currentUser!.uid).set({
        'route': selectedRoute,
        'licensePlate': _licensePlateController.text.trim(),
        'driverId': currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        busLicensePlate = _licensePlateController.text.trim();
        hasAddedBus = true;
      });

      _startSharingLocation(); // Start sharing location after adding the bus

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding bus: $e')),
      );
    }
  }

  Future<void> _startSharingLocation() async {
    try {
      // Start listening to location changes
      _locationSubscription = location.onLocationChanged.listen((LocationData locationData) async {
        // Update Firestore with the new location in real-time
        await FirebaseFirestore.instance.collection('driver_locations').doc(currentUser!.uid).set({
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'driverId': currentUser!.uid,
          'busLicensePlate': busLicensePlate,
          'route': selectedRoute,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          isSharingLocation = true;

          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_currentLocation),
            );
          }
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing location: $e')),
      );
    }
  }

  Future<void> _stopSharingLocation() async {
    // Stop listening to location changes
    _locationSubscription.cancel();

    // Stop sharing the driver's location in Firestore
    await FirebaseFirestore.instance.collection('driver_locations').doc(currentUser!.uid).delete();
    setState(() {
      isSharingLocation = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location sharing stopped')),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _deleteBus() async {
    try {
      // Delete the bus entry for this driver
      await FirebaseFirestore.instance.collection('driver_buses').doc(currentUser!.uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus license plate deleted')),
      );

      // Clear state and navigate back to add bus screen
      setState(() {
        busLicensePlate = null;
        hasAddedBus = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting bus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasAddedBus ? _buildMapView() : _buildAddBusView();
  }

  Widget _buildAddBusView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bus License Plate'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Bus Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bus_routes').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> routeItems = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc['routeNumber'],
                    child: Text('${doc['routeNumber']} - ${doc['beginning']} to ${doc['destination']}'),
                  );
                }).toList();

                return DropdownButton<String>(
                  value: selectedRoute,
                  hint: const Text('Select a Route'),
                  items: routeItems,
                  onChanged: (value) {
                    setState(() {
                      selectedRoute = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Bus License Plate Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'License Plate Number',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBus,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Add Bus and Share Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Location'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Log out button
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: isSharingLocation ? _stopSharingLocation : _startSharingLocation,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: isSharingLocation ? Colors.red : Colors.green,
                  ),
                  child: Text(isSharingLocation ? 'Stop Sharing Location' : 'Share Location'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _deleteBus,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Delete Bus License Plate'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
