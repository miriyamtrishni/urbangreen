import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notificationData;
  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationData, required this.notificationId});

  @override
  _NotificationDetailScreenState createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isMarked = false;

  @override
  void initState() {
    super.initState();
    _isMarked = widget.notificationData['isMarked'] ?? false;
  }

  void _toggleMark() {
    setState(() {
      _isMarked = !_isMarked;
    });
    FirebaseFirestore.instance.collection('notifications').doc(widget.notificationId).update({
      'isMarked': _isMarked,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
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
            // CEB Header with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                  children: [
                    Text(
                      'CEB', // Title
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    widget.notificationData['companyIconUrl'] ?? '',
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description Text
            Text(
              widget.notificationData['description'],
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
                backgroundColor: Colors.green,
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
