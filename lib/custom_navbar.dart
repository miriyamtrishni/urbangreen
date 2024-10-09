import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: selectedIndex == 0 ? Colors.green : Colors.black, // Green when selected
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.people,
            color: selectedIndex == 1 ? Colors.green : Colors.black, // Green when selected
          ),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.directions_bus,
            color: selectedIndex == 2 ? Colors.green : Colors.black, // Green when selected
          ),
          label: 'Bus',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications,
            color: selectedIndex == 3 ? Colors.green : Colors.black, // Green when selected
          ),
          label: 'Notification',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: selectedIndex == 4 ? Colors.green : Colors.black, // Green when selected
          ),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.black,
      onTap: (index) {
        onItemTapped(index); // Call the method to update index
        _navigateToScreen(index, context); // Navigate to the correct screen
      },
    );
  }

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
}
