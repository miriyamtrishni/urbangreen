// lib/screens/community/community_feed_screen.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../../widgets/custom_navbar.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';
import 'comments_screen.dart';
import '../../utils/constants.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({Key? key}) : super(key: key);

  @override
  _CommunityFeedScreenState createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  int _selectedIndex = 1; // Set Community as initially selected
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigation is handled within CustomNavBar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs.map((doc) {
            return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _buildPostCard(posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Create Post Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    bool isPostOwner = post.userId == currentUserId; // Check if the current user is the post owner
    bool isLiked = post.likes.contains(currentUserId); // Check if the current user has liked the post

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.imageUrl),
            ),
            title: Text(post.username),
            subtitle: Text(post.location),
            trailing: isPostOwner
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        // Navigate to the Edit Post screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPostScreen(postId: post.id, postData: post),
                          ),
                        );
                      } else if (value == 'Delete') {
                        _deletePost(post.id, post.imageUrl);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                    ],
                  )
                : null, // If not the owner, do not show the PopupMenuButton
          ),
          if (post.imageUrl.isNotEmpty)
            Image.network(
              post.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post.caption),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleLike(post.id, post.likes),
              ),
              Text('${post.likes.length} likes'), // Display the number of likes
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () {
                  _showComments(post.id, post); // Display comments section
                },
              ),
              const Text('Comments'),
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
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  // Show comments screen
  void _showComments(String postId, PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(postId: postId, postData: post),
      ),
    );
  }
}
