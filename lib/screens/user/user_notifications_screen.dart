// lib/screens/user/user_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/custom_navbar.dart';
import 'notification_detail_screen.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({Key? key}) : super(key: key);

  @override
  _UserNotificationScreenState createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  int _selectedIndex = 3; // Set Notification as initially selected
  String _filter = 'Marked'; // Default filter for notifications
  String _categoryFilter = 'All'; // Category filter: All, CEB, Waterboard

  final Stream<QuerySnapshot> _notificationStream =
      FirebaseFirestore.instance.collection('notifications').snapshots();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // No need to call CustomNavBar.navigateToScreen here
  }

  void _setFilter(String filter) {
    setState(() {
      _filter = filter;
    });
  }

  void _setCategoryFilter(String category) {
    setState(() {
      _categoryFilter = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Notifications'),
      ),
      body: Column(
        children: [
          // Category Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCategoryButton('All'),
                _buildCategoryButton('CEB'),
                _buildCategoryButton('Waterboard'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _notificationStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading notifications"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No notifications available"));
                }

                // Filter notifications based on category and marked/unmarked
                List<DocumentSnapshot> filteredNotifications =
                    snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data()! as Map<String, dynamic>;
                  bool categoryMatches = _categoryFilter == 'All' ||
                      data['category'] == _categoryFilter;
                  if (!categoryMatches) return false;

                  if (_filter == 'Marked' && data['isMarked'] == true)
                    return true;
                  if (_filter == 'Unmarked' &&
                      (data['isMarked'] == false || data['isMarked'] == null))
                    return true;
                  return false;
                }).toList();

                return ListView(
                  children: filteredNotifications.map((doc) {
                    NotificationModel notification = NotificationModel.fromMap(
                        doc.data()! as Map<String, dynamic>, doc.id);
                    return ListTile(
                      leading: notification.companyIconUrl != null
                          ? Image.network(notification.companyIconUrl!,
                              width: 40, height: 40)
                          : null,
                      title: Text(notification.title),
                      subtitle: Text(
                        notification.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing:
                          Text(_getTimeDifference(notification.createdAt)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailScreen(
                              notification: notification,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      // Mark and Unmark buttons in a bar at the bottom
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mark and Unmark Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _setFilter('Marked');
                  },
                  icon: const Icon(Icons.mark_email_read),
                  label: const Text('Marked'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Marked'
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _setFilter('Unmarked');
                  },
                  icon: const Icon(Icons.mark_email_unread),
                  label: const Text('Unmarked'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Unmarked'
                        ? AppColors.primaryColor
                        : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
              ],
            ),
          ),
          CustomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ],
      ),
    );
  }

  // Widget for building category buttons
  Widget _buildCategoryButton(String categoryLabel) {
    return GestureDetector(
      onTap: () {
        _setCategoryFilter(categoryLabel);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _categoryFilter == categoryLabel
              ? AppColors.primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          categoryLabel,
          style: TextStyle(
            color: _categoryFilter == categoryLabel
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper method to format time difference
  String _getTimeDifference(Timestamp timestamp) {
    final difference = DateTime.now().difference(timestamp.toDate());
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
