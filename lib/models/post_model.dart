// lib/models/post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String caption;
  final String location;
  final String category;
  final String imageUrl;
  final Timestamp createdAt;
  final List<dynamic> likes;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.caption,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
    required this.likes,
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      caption: data['caption'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      likes: data['likes'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'caption': caption,
      'location': location,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}
