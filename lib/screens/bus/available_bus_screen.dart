// lib/screens/bus/available_bus_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bus_location_map_screen.dart';
import '../../widgets/custom_navbar.dart';

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
        title: Text('Buses on Route ${widget.routeNumber}'),
        backgroundColor: Colors.green,
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
              return ListTile(
                title: Text('Bus License: ${busData['licensePlate']}'),
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
