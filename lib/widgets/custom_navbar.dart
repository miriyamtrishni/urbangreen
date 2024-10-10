// lib/widgets/custom_navbar.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  void _navigateToScreen(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/community');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/bus');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/notification');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(Icons.home, 'Home', 0),
        _buildNavItem(Icons.people, 'Community', 1),
        _buildNavItem(Icons.directions_bus, 'Bus', 2),
        _buildNavItem(Icons.notifications, 'Notification', 3),
        _buildNavItem(Icons.person, 'Profile', 4),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.accentColor,
      onTap: (index) {
        onItemTapped(index);
        _navigateToScreen(index, context);
      },
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: selectedIndex == index ? AppColors.primaryColor : AppColors.accentColor,
      ),
      label: label,
    );
  }
}
