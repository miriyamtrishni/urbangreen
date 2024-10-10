// lib/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String? companyIconUrl;
  final Timestamp createdAt;
  final bool isMarked;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.companyIconUrl,
    required this.createdAt,
    this.isMarked = false,
  });

  // Factory method to create a NotificationModel from a map
  factory NotificationModel.fromMap(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      companyIconUrl: data['companyIconUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isMarked: data['isMarked'] ?? false,
    );
  }

  // Method to convert NotificationModel to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'companyIconUrl': companyIconUrl,
      'createdAt': createdAt,
      'isMarked': isMarked,
    };
  }
}
