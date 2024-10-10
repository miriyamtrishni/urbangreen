// lib/screens/user/notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({Key? key, required this.notification})
      : super(key: key);

  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isMarked = false;

  @override
  void initState() {
    super.initState();
    _isMarked = widget.notification.isMarked;
  }

  void _toggleMark() {
    setState(() {
      _isMarked = !_isMarked;
    });
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(widget.notification.id)
        .update({
      'isMarked': _isMarked,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company Header with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      widget.notification.category,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.phone, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          '011 2 563 583', // Static number or use dynamic if applicable
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Company Logo/Image
                widget.notification.companyIconUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          widget.notification.companyIconUrl!,
                          width: 80,
                          height: 80,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 16),
            // Description Text
            Text(
              widget.notification.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // "More information" text
            TextButton(
              onPressed: () {
                // Action for more information if any
              },
              child: const Text(
                'More information.',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const Spacer(),
            // Mark/Unmark Button
            ElevatedButton(
              onPressed: _toggleMark,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: const Size(double.infinity, 50), // Full width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded edges
                ),
              ),
              child: Text(_isMarked ? 'Unmark' : 'Mark'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
