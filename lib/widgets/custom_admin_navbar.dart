// lib/widgets/custom_admin_navbar.dart
import 'package:flutter/material.dart';
import 'package:urbangreen/screens/admin/add_bus_route_screen.dart';
import 'package:urbangreen/screens/admin/admin_home_screen.dart';
import 'package:urbangreen/screens/admin/admin_profile_screen.dart';
import '../utils/constants.dart'; // Assuming your theme colors are in constants.dart

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
        _buildNavItem(Icons.notifications, 'Notifications', 0),
        _buildNavItem(Icons.add_location_alt, 'Add Route', 1),
        _buildNavItem(Icons.person, 'Profile', 2), // Add Profile item
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primaryColor, // Using theme color
      unselectedItemColor: AppColors.accentColor, // Using theme color
      onTap: (index) {
        onItemTapped(index);
        _navigateToScreen(index, context);
      },
    );
  }

  // Helper method to build navigation items
  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: selectedIndex == index ? AppColors.primaryColor : AppColors.accentColor,
      ),
      label: label,
    );
  }

  // Navigation logic based on the selected item
  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        // Navigate to Add Notification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
        break;
      case 1:
        // Navigate to Add Bus Route screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AddBusRouteScreen()),
        );
        break;
      case 2:
        // Navigate to Profile screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminProfileScreen()),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
        );
        break;
    }
  }
}
