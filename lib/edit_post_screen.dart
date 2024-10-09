import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_navbar.dart';  // Import the custom navigation bar

class EditPostScreen extends StatefulWidget {
  final String postId;
  final DocumentSnapshot postData;

  const EditPostScreen({super.key, required this.postId, required this.postData});

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  int _selectedIndex = 1; // Set Community as initially selected
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _category;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.postData['caption'];
    _locationController.text = widget.postData['location'];
    _category = widget.postData['category'];
    _imageUrl = widget.postData['imageUrl'];
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _updatePost() async {
    try {
      // If a new image is selected, upload it and get the URL
      if (_imageFile != null) {
        String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
        UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        _imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update the post data in Firestore
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
        'caption': _captionController.text,
        'location': _locationController.text,
        'category': _category,
        'imageUrl': _imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully')));
      Navigator.pop(context); // Go back to the feed after a successful update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          TextButton(
            onPressed: _updatePost,
            child: const Text('Save', style: TextStyle(color: Color.fromARGB(255, 156, 32, 32))), // Save button in AppBar
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover)
            else if (_imageUrl != null)
              Image.network(_imageUrl!, height: 250, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo),
              label: const Text('Change Photo'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Edit Caption',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Edit Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _category,
              items: ['General', 'Environment', 'Infrastructure']
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Edit Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
