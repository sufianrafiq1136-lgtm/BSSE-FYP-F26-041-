import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItemModel {
  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final bool isCompleted;
  final bool repeatDaily;
  final int notificationId;
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoItemModel({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.isCompleted,
    required this.repeatDaily,
    required this.notificationId,
    this.description,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt,
      'isCompleted': isCompleted,
      'repeatDaily': repeatDaily,
      'notificationId': notificationId,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  factory TodoItemModel.fromMap(String id, Map<String, dynamic> map) {
    return TodoItemModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      scheduledAt:
          (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      repeatDaily: map['repeatDaily'] ?? true,
      notificationId: map['notificationId'] ?? 0,
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  TodoItemModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    bool? isCompleted,
    bool? repeatDaily,
    int? notificationId,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
