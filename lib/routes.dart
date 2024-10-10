// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/community/community_feed_screen.dart';
import 'screens/bus/bus_screen.dart';
import 'screens/user/user_notifications_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/community/create_post_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/add_notification_screen.dart';

Map<String, WidgetBuilder> routes = {
  '/home': (context) => const UserHomeScreen(),
  '/community': (context) => const CommunityFeedScreen(),
  '/bus': (context) => const BusScreen(),
  '/notification': (context) => const UserNotificationScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/login': (context) => const LoginScreen(),
  '/add_post': (context) => const CreatePostScreen(),
  '/admin_home': (context) => const AdminHomeScreen(),
  '/add_notification': (context) => const AddNotificationScreen(),
  // Add other routes as needed
};
