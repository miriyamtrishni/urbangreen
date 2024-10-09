import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_navbar.dart'; // Your custom nav bar
import 'notification_detail_screen.dart'; // For showing the notification details

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  _UserNotificationScreenState createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  int _selectedIndex = 1; // Set Notification as initially selected
  String _filter = 'Marked'; // Default filter for notifications
  String _categoryFilter = 'All'; // Category filter: All, CEB, Waterboard

  final Stream<QuerySnapshot> _notificationStream = FirebaseFirestore.instance.collection('notifications').snapshots();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        backgroundColor: Colors.green,
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

                // Filter notifications based on category and marked/unmarked
                List<DocumentSnapshot> filteredNotifications = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                  bool categoryMatches = _categoryFilter == 'All' || data['category'] == _categoryFilter;
                  if (!categoryMatches) return false;

                  if (_filter == 'Marked' && data['isMarked'] == true) return true;
                  if (_filter == 'Unmarked' && (data['isMarked'] == false || data['isMarked'] == null)) return true;
                  return false;
                }).toList();

                return ListView(
                  children: filteredNotifications.map((doc) {
                    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: Image.network(data['companyIconUrl'] ?? '', width: 40, height: 40),
                      title: Text(data['title']),
                      subtitle: Text(
                        data['description'],
                        maxLines: 2, // Show only two lines of the description
                        overflow: TextOverflow.ellipsis, // Add "..." if text overflows
                      ),
                      trailing: const Text("3h"), // Placeholder for time
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailScreen(
                              notificationData: data,
                              notificationId: doc.id,
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
                  label: const Text('Mark'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Marked' ? Colors.green : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _setFilter('Unmarked');
                  },
                  icon: const Icon(Icons.mark_email_unread),
                  label: const Text('Unmark'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filter == 'Unmarked' ? Colors.green : Colors.grey.shade300,
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _categoryFilter == categoryLabel ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          categoryLabel,
          style: TextStyle(
            color: _categoryFilter == categoryLabel ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
