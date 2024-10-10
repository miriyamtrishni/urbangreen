// lib/widgets/custom_admin_navbar.dart
import 'package:flutter/material.dart';
import 'package:urbangreen/screens/admin/add_bus_route_screen.dart';
import 'package:urbangreen/screens/admin/add_notification_screen.dart';


class CustomAdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomAdminNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications,
            color: selectedIndex == 0 ? Colors.green : Colors.black,
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_location_alt,
            color: selectedIndex == 1 ? Colors.green : Colors.black,
          ),
          label: 'Add Route',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        onItemTapped(index);
        _navigateToScreen(index, context); // Navigate based on index
      },
    );
  }

  // Navigation logic based on the selected item
  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Navigate to Add Notification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddNotificationScreen()),
        );
        break;
      case 1:
        // Navigate to Add Bus Route screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddBusRouteScreen()), // Assuming you'll create this screen
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddNotificationScreen()),
        );
        break;
    }
  }
}
