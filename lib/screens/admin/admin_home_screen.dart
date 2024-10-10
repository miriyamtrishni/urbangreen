// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_notification_screen.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_admin_navbar.dart'; // Import the custom admin nav bar

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // Stream to listen for notifications in Firestore
  final Stream<QuerySnapshot> _notificationStream =
      FirebaseFirestore.instance.collection('notifications').snapshots();
  
  int _selectedIndex = 0; // Set Notifications as initially selected

  // Handle navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add notification screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddNotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationStream,
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          // Group notifications into "Last 7 days" and "Last 30 days"
          List<DocumentSnapshot> last7Days = snapshot.data!.docs
              .where((doc) => _isWithinLastDays(doc, 7))
              .toList();
          List<DocumentSnapshot> last30Days = snapshot.data!.docs
              .where((doc) =>
                  !_isWithinLastDays(doc, 7) && _isWithinLastDays(doc, 30))
              .toList();

          return ListView(
            children: [
              _buildSectionTitle('Last 7 Days'),
              _buildNotificationList(last7Days),
              _buildSectionTitle('Last 30 Days'),
              _buildNotificationList(last30Days),
            ],
          );
        },
      ),
      // Add the custom admin nav bar
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  bool _isWithinLastDays(DocumentSnapshot doc, int days) {
    Timestamp timestamp = doc['createdAt'];
    DateTime notificationDate = timestamp.toDate();
    return notificationDate
        .isAfter(DateTime.now().subtract(Duration(days: days)));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationList(List<DocumentSnapshot> notifications) {
    return Column(
      children: notifications.map((doc) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        NotificationModel notification =
            NotificationModel.fromMap(data, doc.id);
        return ListTile(
          leading: notification.companyIconUrl != null
              ? Image.network(notification.companyIconUrl!,
                  width: 40, height: 40)
              : null, // Display the icon if available
          title: Text(notification.title),
          subtitle: Text(notification.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to the edit notification screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNotificationScreen(
                        notificationId: notification.id,
                        existingData: notification,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _deleteNotification(notification.id);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Delete the notification from Firestore
  void _deleteNotification(String notificationId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted successfully')),
    );
  }
}
