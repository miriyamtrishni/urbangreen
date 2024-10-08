import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_navbar.dart';
import 'login_screen.dart';
import 'dart:io';

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
  String? _profileImageUrl; // For storing the user's profile image URL

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
        _profileImageUrl = userDoc.get('profileImage'); // Fetch profile image URL if exists
      }
      setState(() {});
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

  // Upload profile image to Firebase Storage
  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Reference storageReference = FirebaseStorage.instance.ref().child('profile_pics/${_currentUser!.uid}');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL for the image
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile image URL in Firestore
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({
        'profileImage': downloadURL,
      });

      setState(() {
        _profileImageUrl = downloadURL;
      });
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
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
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
            Container(
              height: 150,
              color: Colors.green,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : AssetImage('assets/default_profile.png'), // Default image if no profile image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _uploadImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _nameController.text,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        selectedIndex: _selectedIndex,
        onItemTapped: (int value) {
          setState(() {
            _selectedIndex = value;
          });
        },
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
