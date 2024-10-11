// lib/screens/bus/available_bus_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bus_location_map_screen.dart';
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart'; // Assuming you have a constants file for colors

class AvailableBusScreen extends StatefulWidget {
  final String routeNumber;
  const AvailableBusScreen({Key? key, required this.routeNumber}) : super(key: key);

  @override
  _AvailableBusScreenState createState() => _AvailableBusScreenState();
}

class _AvailableBusScreenState extends State<AvailableBusScreen> {
  int _selectedIndex = 2; // Set Bus as initially selected

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
        title: Text(
          'Buses on Route ${widget.routeNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor, // Adjusted to match your app’s theme
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 70, // Adjusted height to make it more consistent
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('driver_buses')
            .where('route', isEqualTo: widget.routeNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var buses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              var busData = buses[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  elevation: 5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: const Icon(Icons.directions_bus, color: Colors.green),
                    title: Text(
                      'Bus License: ${busData['licensePlate']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusLocationMapScreen(
                            busId: busData.id,
                            licensePlate: busData['licensePlate'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
