// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_notification_screen.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_admin_navbar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Stream<QuerySnapshot> _notificationStream =
      FirebaseFirestore.instance.collection('notifications').snapshots();

  int _selectedIndex = 0;

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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available"));
          }

          List<DocumentSnapshot> last7Days = snapshot.data!.docs
              .where((doc) => _isWithinLastDays(doc, 7))
              .toList();
          List<DocumentSnapshot> last30Days = snapshot.data!.docs
              .where((doc) => !_isWithinLastDays(doc, 7) && _isWithinLastDays(doc, 30))
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotificationScreen()),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomAdminNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  bool _isWithinLastDays(DocumentSnapshot doc, int days) {
    Timestamp timestamp = doc['createdAt'];
    DateTime notificationDate = timestamp.toDate();
    return notificationDate.isAfter(DateTime.now().subtract(Duration(days: days)));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.companyIconUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      notification.companyIconUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        notification.description,
                        maxLines: 1,  // Limit to one line
                        overflow: TextOverflow.ellipsis,  // Add ellipsis if text is too long
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
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
          ),
        );
      }).toList(),
    );
  }

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
