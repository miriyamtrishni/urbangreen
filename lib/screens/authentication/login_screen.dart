// lib/screens/authentication/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_home_screen.dart';
import '../user/user_home_screen.dart';
import '../driver/driver_home_screen.dart'; // Import the DriverHomeScreen
import '../../utils/constants.dart';
import '../../services/authentication_service.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        UserModel user = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>, userDoc.id);

        // Navigate based on role
        if (user.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
          );
        } else if (user.role == 'driver') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          );
        }
      } else {
        // If user document doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Error: $e')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential = await _authService.signInWithGoogle();

      // Check if user data exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // New user, save data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'role': 'user', // Default role
        });
      }

      // Fetch role
      String role =
          (userDoc.data() as Map<String, dynamic>?)?['role'] ?? 'user';

      // Navigate based on role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        );
      } else if (role == 'driver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome back,',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text('Login to your account'),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter email or username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.visibility_off),
                ),
                obscureText: true,
              ),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (bool? value) {}),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.primaryColor,
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey.shade300,
                ),
                icon: Image.asset('assets/google_icon.png', height: 24),
                label: const Text('Login with Google'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
