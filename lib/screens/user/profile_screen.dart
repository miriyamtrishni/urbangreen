// lib/screens/user/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_navbar.dart';
import '../../utils/constants.dart';
import '../authentication/login_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
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
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .update({
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
            await _currentUser!
                .updatePassword(_passwordController.text.trim());
          }

          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')));
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Profile update failed: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords do not match')));
    }
  }

  // Upload profile image to Firebase Storage
  Future<void> _uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pics/${_currentUser!.uid}');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL for the image
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Update the user's profile image URL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
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
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // No need to call CustomNavBar.navigateToScreen here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              'Edit profile',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            TextButton(
              onPressed: _updateProfile,
              child: const Text(
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
              color: AppColors.primaryColor,
              child: Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider, // Default image if no profile image
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon:
                            const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _uploadImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _nameController.text,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Enter your name'),
                  const SizedBox(height: 10),
                  _buildTextField(_usernameController, 'Enter username'),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Enter your email'),
                  const SizedBox(height: 10),
                  _buildPasswordField(_passwordController, 'Create password'),
                  const SizedBox(height: 10),
                  _buildPasswordField(
                      _reEnterPasswordController, 'Re-enter password'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.accentColor,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
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
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        suffixIcon:
            const Icon(Icons.visibility_off, color: AppColors.primaryColor),
      ),
    );
  }
}
