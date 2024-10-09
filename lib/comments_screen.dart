import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final DocumentSnapshot postData;  // Pass the post data to the comments screen

  const CommentsScreen({super.key, required this.postId, required this.postData});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get current user's UID

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;
    try {
      // Add the comment to Firestore
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).collection('comments').add({
        'userId': currentUserId,
        'comment': _commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'username': FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
      });
      _commentController.clear(); // Clear the input field
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          // Display the full post details at the top
          Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.postData['imageUrl'] != null)
                  Image.network(
                    widget.postData['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(widget.postData['caption'] ?? 'No caption'),
                ),
              ],
            ),
          ),
          // Comments section
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot comment = snapshot.data!.docs[index];
                    String username = comment['username'] ?? 'Anonymous';  // Ensure the username is not null
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',  // Handle empty or null usernames
                        ),
                      ),
                      title: Text(username),
                      subtitle: Text(comment['comment']),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
