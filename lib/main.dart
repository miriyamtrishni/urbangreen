import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbangreen/community_feed_screen.dart';
import 'package:urbangreen/create_post_screen.dart';
import 'login_screen.dart';
import 'user_home_screen.dart';
import 'profile_screen.dart';  // Import Profile screen
import 'community_screen.dart'; // Assuming you have these screens
import 'bus_screen.dart';
import 'notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user is already logged in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Set the initial home screen based on login status
  Widget initialScreen = isLoggedIn ? UserHomeScreen() : LoginScreen();

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  MyApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanGreen',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Define the routes
      routes: {
        '/home': (context) => UserHomeScreen(),
        
        '/community': (context) => CommunityFeedScreen(),
        '/bus': (context) => BusScreen(),
        '/notification': (context) => NotificationScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/add_post': (context) => CreatePostScreen(),
      },
      home: initialScreen,  // Start with the initial screen
    );
  }
}
