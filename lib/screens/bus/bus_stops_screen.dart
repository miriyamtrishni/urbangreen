// lib/screens/bus/bus_stops_screen.dart

import 'package:flutter/material.dart';
import 'package:urbangreen/utils/constants.dart'; // Assuming you have a constants file for colors
import 'package:urbangreen/widgets/custom_navbar.dart'; // Assuming you have a custom navigation bar

class BusStopsScreen extends StatelessWidget {
  final String routeNumber;
  final List<dynamic> busStops;

  const BusStopsScreen({
    Key? key,
    required this.routeNumber,
    required this.busStops,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Bus Stops',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: busStops.length,
                itemBuilder: (context, index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Leading part with the line and icons
                      Column(
                        children: [
                          Container(
                            width: 40,
                            child: Column(
                              children: [
                                // Bus stop icon (solid circle for all stops)
                                Icon(
                                  Icons.circle,
                                  color: AppColors.primaryColor,
                                  size: 24,
                                ),
                                if (index != busStops.length - 1)
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: AppColors.primaryColor,
                                  ), // Line between stops
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10), // Spacing between icon and text
                      // Text for the bus stop name
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            busStops[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
      // Adding your custom navigation bar here
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 2, // Assuming Bus tab is at index 2
        onItemTapped: (index) {
          // Handle the navigation bar taps if needed
        },
      ),
    );
  }
}
