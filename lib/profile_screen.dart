import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_navbar.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4; // Set Profile as initially selected

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();
  
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch user data from Firebase
  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        _nameController.text = userDoc.get('name');
        _usernameController.text = userDoc.get('username');
        _emailController.text = userDoc.get('email');
      }
    }
  }

  // Update profile data in Firebase
  Future<void> _updateProfile() async {
    if (_passwordController.text == _reEnterPasswordController.text) {
      try {
        if (_currentUser != null) {
          // Update user data in Firestore
          await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
            'name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
          });

          // Update email in Firebase Authentication if changed
          if (_emailController.text.trim() != _currentUser!.email) {
            await _currentUser!.updateEmail(_emailController.text.trim());
          }

          // Update password in Firebase Authentication if changed
          if (_passwordController.text.isNotEmpty) {
            await _currentUser!.updatePassword(_passwordController.text.trim());
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile update failed: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
    }
  }

  // Log out the user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0, // No shadow under the AppBar
        automaticallyImplyLeading: false, // Removes the default back arrow
        toolbarHeight: 100, // Sets height of the AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Text(
              'Edit profile',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            TextButton(
              onPressed: _updateProfile,
              child: Text(
                'Save',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Green background for the profile header
            Container(
              height: 150,
              color: Colors.green,
              child: Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    'https://example.com/path_to_your_image.jpg', // Replace with the user image URL
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            // User Name under the avatar
            Text(
              _nameController.text, // User's name fetched from Firebase
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Enter your name'),
                  SizedBox(height: 10),
                  _buildTextField(_usernameController, 'Enter username'),
                  SizedBox(height: 10),
                  _buildTextField(_emailController, 'Enter your email'),
                  SizedBox(height: 10),
                  _buildPasswordField(_passwordController, 'Create password'),
                  SizedBox(height: 10),
                  _buildPasswordField(_reEnterPasswordController, 'Re-enter password'),
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex, onItemTapped: (int value) {  },
        
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
        ),
        suffixIcon: Icon(Icons.visibility_off, color: Colors.green),
      ),
    );
  }
}
