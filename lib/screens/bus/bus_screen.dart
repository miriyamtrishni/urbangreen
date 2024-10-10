// lib/screens/bus/bus_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({Key? key}) : super(key: key);

  @override
  _BusScreenState createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
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
        title: const Text('Bus Screen'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: const Center(
        child: Text('Welcome to the Bus Screen!'),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
