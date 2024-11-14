import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../../widgets/custom_navbar.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';
import 'comments_screen.dart';

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
        title: const Text(
          'Community',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.group, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.black),
            onPressed: () {
              // Navigate to Create Post Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
          ),
        ],
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.imageUrl),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Location: ${post.location}', style: const TextStyle(color: Colors.black)),
              ],
            ),
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
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () => _toggleLike(post.id, post.likes),
                ),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.black),
                  onPressed: () {
                    _showComments(post.id, post); // Display comments section
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('${post.likes.length} likes', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: post.username,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: ' ${post.caption}',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                _showComments(post.id, post); // Display comments section
              },
              child: const Text('View all comments', style: TextStyle(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 10),
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