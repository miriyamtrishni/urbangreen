// lib/screens/user/user_home_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0; // Set Home as initially selected

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Dummy data for demonstration
  final List<Map<String, String>> alerts = [
    {
      'title': 'Heavy Traffic',
      'imageUrl':
          'https://www.example.com/images/traffic.jpg', // Replace with actual image URLs
    },
    {
      'title': 'Emergency Power Outage',
      'imageUrl': 'https://www.example.com/images/power_outage.jpg',
    },
  ];

  final List<Map<String, String>> notifications = [
    {
      'message':
          'Scheduled power outage from 1:00 PM to 4:00 PM in your area on September 15',
      'time': '3h',
    },
    // Add more notifications as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: _buildSearchBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerts Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildAlertsSection(),

            // Recent Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recent',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildRecentSection(),

            // Notification Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildNotificationSection(),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Search bar widget
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.secondaryColor,
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          hintText: 'Search',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Alerts section with images
  Widget _buildAlertsSection() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return _buildAlertCard(
            alerts[index]['title']!,
            alerts[index]['imageUrl']!,
          );
        },
      ),
    );
  }

  // Alert card widget
  Widget _buildAlertCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Recent section with map (static image for demo)
  Widget _buildRecentSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          'https://www.example.com/images/map.jpg', // Replace with actual map image URL
          fit: BoxFit.cover,
          height: 150,
        ),
      ),
    );
  }

  // Notification section widget
  Widget _buildNotificationSection() {
    return Column(
      children: notifications.map((notification) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 1)
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.yellow, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['message']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time']!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
