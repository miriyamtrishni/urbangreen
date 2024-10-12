// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'routes.dart'; // Import the routes
import 'utils/theme.dart'; // Import your app theme

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanGreen',
      theme: appTheme, // Apply your custom theme
      initialRoute: '/splash', // Set splash screen as the initial route
      routes: routes, // Use the routes map from routes.dart
      debugShowCheckedModeBanner: false,
    );
  }
}
