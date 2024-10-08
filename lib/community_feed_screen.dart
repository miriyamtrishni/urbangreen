import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'edit_post_screen.dart'; // Import the Edit Post screen
import 'create_post_screen.dart'; // Import the Create Post screen
import 'custom_navbar.dart'; // Import the custom navigation bar
import 'comments_screen.dart'; // Import the Comments screen

class CommunityFeedScreen extends StatefulWidget {
  @override
  _CommunityFeedScreenState createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  int _selectedIndex = 1; // Set Community as initially selected
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Feed'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot post = snapshot.data!.docs[index];
              return _buildPostCard(post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Post Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        child: Icon(Icons.add), // Add icon for creating a new post
        backgroundColor: Colors.green, // Floating button color
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildPostCard(DocumentSnapshot post) {
    bool isPostOwner = post['userId'] == currentUserId;  // Check if the current user is the post owner
    List likes = (post.data() as Map<String, dynamic>).containsKey('likes') ? post['likes'] : [];  // Safely handle missing "likes" field
    bool isLiked = likes.contains(currentUserId);  // Check if the current user has liked the post

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post['imageUrl']),
            ),
            title: Text(post['username'] ?? 'Anonymous'),
            subtitle: Text(post['location'] ?? 'Location not provided'),
            trailing: isPostOwner ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  // Navigate to the Edit Post screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditPostScreen(postId: post.id, postData: post)),
                  );
                } else if (value == 'Delete') {
                  _deletePost(post.id, post['imageUrl']);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              ],
            ) : null,  // If not the owner, do not show the PopupMenuButton
          ),
          if (post['imageUrl'] != null)
            Image.network(
              post['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post['caption'] ?? 'No caption'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleLike(post.id, likes),
              ),
              Text('${likes.length} likes'), // Display the number of likes
              Spacer(),
              IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  _showComments(post.id, post);  // Display comments section
                },
              ),
              Text('Comments'),
            ],
          ),
        ],
      ),
    );
  }

  // Function to toggle like
  Future<void> _toggleLike(String postId, List likes) async {
    try {
      if (likes.contains(currentUserId)) {
        // Unlike the post
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Like the post
        await FirebaseFirestore.instance.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to like post: $e')));
    }
  }

  // Function to delete post and associated image
  Future<void> _deletePost(String postId, String imageUrl) async {
    try {
      // Delete the post from Firestore
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

      // Delete the image from Firebase Storage
      if (imageUrl != null) {
        FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  // Show comments screen
  void _showComments(String postId, DocumentSnapshot post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(postId: postId, postData: post)),
    );
  }
}
