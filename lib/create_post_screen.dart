import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'community_feed_screen.dart'; // Import feed screen

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _category;
  bool _notifyOthers = false;
  File? _imageFile;

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask uploadTask = _firebaseStorage.ref(fileName).putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _createPost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add a photo')));
      return;
    }

    try {
      // Upload image to Firebase storage
      String imageUrl = await _uploadImage(_imageFile!);

      // Save post details to Firestore
      await _firebaseFirestore.collection('posts').add({
        'userId': _firebaseAuth.currentUser?.uid,
        'username': _firebaseAuth.currentUser?.displayName ?? 'Anonymous',
        'caption': _captionController.text,
        'location': _locationController.text,
        'category': _category,
        'notifyOthers': _notifyOthers,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Navigate back to Feed after successful post
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CommunityFeedScreen()));
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created successfully')));

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imageFile != null)
              Image.file(_imageFile!, height: 250, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo),
              label: Text('Add Photo'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Add Caption',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
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
            ),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text('Notify Others'),
              value: _notifyOthers,
              onChanged: (value) {
                setState(() {
                  _notifyOthers = value!;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Post'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
