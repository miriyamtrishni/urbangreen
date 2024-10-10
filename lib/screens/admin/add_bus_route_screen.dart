import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/route_model.dart';
import '../../widgets/custom_admin_navbar.dart';

class AddBusRouteScreen extends StatefulWidget {
  const AddBusRouteScreen({Key? key}) : super(key: key);

  @override
  _AddBusRouteScreenState createState() => _AddBusRouteScreenState();
}

class _AddBusRouteScreenState extends State<AddBusRouteScreen> {
  final TextEditingController _routeNumberController = TextEditingController();
  final TextEditingController _beginningController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<TextEditingController> _busStopControllers = []; // Controllers for bus stops

  int _selectedIndex = 1;

  @override
  void dispose() {
    // Clean up controllers when the screen is disposed
    _routeNumberController.dispose();
    _beginningController.dispose();
    _destinationController.dispose();
    for (var controller in _busStopControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addOrUpdateRoute({String? routeId}) async {
    if (_routeNumberController.text.isEmpty ||
        _beginningController.text.isEmpty ||
        _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      List<String> busStops = _busStopControllers
          .map((controller) => controller.text.trim())
          .where((stop) => stop.isNotEmpty)
          .toList();

      if (busStops.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one bus stop')),
        );
        return;
      }

      Map<String, dynamic> routeData = {
        'routeNumber': _routeNumberController.text.trim(),
        'beginning': _beginningController.text.trim(),
        'destination': _destinationController.text.trim(),
        'busStops': busStops,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (routeId != null) {
        // Update existing route
        await FirebaseFirestore.instance
            .collection('bus_routes')
            .doc(routeId)
            .update(routeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus route updated successfully')),
        );
      } else {
        // Add new route
        await FirebaseFirestore.instance.collection('bus_routes').add(routeData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bus route added successfully')),
        );
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving bus route: $e')),
      );
    }
  }

  void _clearForm() {
    _routeNumberController.clear();
    _beginningController.clear();
    _destinationController.clear();
    _busStopControllers.forEach((controller) => controller.clear());
    _busStopControllers = [];
    setState(() {}); // To re-render UI after clearing the list
  }

  void _addBusStopField() {
    setState(() {
      _busStopControllers.add(TextEditingController());
    });
  }

  void _removeBusStopField(int index) {
    setState(() {
      _busStopControllers.removeAt(index);
    });
  }

  Future<void> _editRoute(String routeId, RouteModel routeData) async {
    // Load data into form for editing
    _routeNumberController.text = routeData.routeNumber;
    _beginningController.text = routeData.beginning;
    _destinationController.text = routeData.destination;
    _busStopControllers.clear();
    routeData.busStops.forEach((stop) {
      _busStopControllers.add(TextEditingController(text: stop));
    });

    // Show the pop-up to update
    _showAddRoutePopup(routeId: routeId);
  }

  void _showAddRoutePopup({String? routeId}) {
    // Clear the form when opening the dialog for adding a new route
    if (routeId == null) {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, // Wider pop-up
                height: MediaQuery.of(context).size.height * 0.85, // Taller pop-up
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(routeId != null ? 'Edit Route' : 'Add Route',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _routeNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Route Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _beginningController,
                        decoration: const InputDecoration(
                          labelText: 'Beginning',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _destinationController,
                        decoration: const InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          const Text('Bus Stops'),
                          ..._busStopControllers.asMap().entries.map((entry) {
                            int index = entry.key;
                            TextEditingController controller = entry.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Bus Stop',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setDialogState(() {
                                      _removeBusStopField(index);
                                    });
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                _addBusStopField();
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Bus Stop'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _addOrUpdateRoute(routeId: routeId);
                              Navigator.pop(context);
                            },
                            child: Text(routeId != null
                                ? 'Update Route'
                                : 'Add Route'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteRoute(String routeId) async {
    await FirebaseFirestore.instance.collection('bus_routes').doc(routeId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bus route deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Bus Route'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRoutePopup(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bus_routes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading routes'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No routes available'));
          }

          List<DocumentSnapshot> routes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              RouteModel route = RouteModel.fromMap(routes[index].data() as Map<String, dynamic>, routes[index].id);

              return ListTile(
                title: Text('${route.routeNumber} - ${route.beginning} to ${route.destination}'),
                subtitle: Text('Stops: ${route.busStops.join(', ')}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editRoute(route.id, route),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteRoute(route.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
