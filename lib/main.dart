// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/theme.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/driver/driver_home_screen.dart';
import 'routes.dart';
import 'models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if the user is already logged in via Firebase
  User? currentUser = FirebaseAuth.instance.currentUser;
  Widget initialScreen;

  if (currentUser != null) {
    // User is logged in, fetch their role from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      UserModel user = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>, userDoc.id);

      // Redirect based on role
      if (user.role == 'admin') {
        initialScreen = const AdminHomeScreen();
      } else if (user.role == 'driver') {
        initialScreen = const DriverHomeScreen();
      } else {
        initialScreen = const UserHomeScreen();
      }
    } else {
      // If user document doesn't exist, navigate to login
      initialScreen = const LoginScreen();
    }
  } else {
    // If no user is logged in, navigate to login screen
    initialScreen = const LoginScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanGreen',
      theme: appTheme,
      routes: routes,
      home: initialScreen,
    );
  }
}
