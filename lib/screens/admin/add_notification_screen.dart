// lib/screens/admin/add_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../models/notification_model.dart';

class AddNotificationScreen extends StatefulWidget {
  final String? notificationId;
  final NotificationModel? existingData;

  const AddNotificationScreen({Key? key, this.notificationId, this.existingData})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _iconFile;
  String? _companyIconUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!.title;
      _descriptionController.text = widget.existingData!.description;
      _selectedCategory = widget.existingData!.category;
      _companyIconUrl = widget.existingData!.companyIconUrl;
    }
  }

  Future<void> _addOrUpdateNotification() async {
    String iconUrl = _companyIconUrl ?? '';
    if (_iconFile != null) {
      iconUrl = await _uploadIcon(_iconFile!);
    }

    if (widget.notificationId != null) {
      // Update the notification
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.notificationId)
          .update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'companyIconUrl': iconUrl,
        'createdAt': Timestamp.now(),
      });
    } else {
      // Add a new notification
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'companyIconUrl': iconUrl,
        'createdAt': Timestamp.now(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Notification ${widget.notificationId != null ? 'updated' : 'added'} successfully')),
    );

    Navigator.pop(context); // Return to the admin home screen
  }

  Future<String> _uploadIcon(File file) async {
    String fileName = 'company_icons/${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _iconFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notificationId != null
            ? 'Edit Notification'
            : 'Add Notification'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Notification Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['CEB', 'Waterboard'].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _iconFile == null
                    ? (_companyIconUrl != null
                        ? Image.network(_companyIconUrl!,
                            width: 50, height: 50)
                        : Container())
                    : Image.file(_iconFile!, width: 50, height: 50),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickIcon,
                  child: const Text('Pick Icon'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrUpdateNotification,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
              child: Text(widget.notificationId != null
                  ? 'Update Notification'
                  : 'Add Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
