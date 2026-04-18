import 'package:cloud_firestore/cloud_firestore.dart';

class BatchModel {
  final String id;
  final String name;
  final int initialCount;
  final int liveCount;
  final int soldCount;
  final double mortalityRate;
  final DateTime dateCreated;
  final String status; // active, completed, archived
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BatchModel({
    required this.id,
    required this.name,
    required this.initialCount,
    required this.liveCount,
    required this.soldCount,
    required this.mortalityRate,
    required this.dateCreated,
    required this.status,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  /// Get age in days from creation date
  int getAgeInDays() {
    return DateTime.now().difference(dateCreated).inDays;
  }

  /// Convert BatchModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'initialCount': initialCount,
      'liveCount': liveCount,
      'soldCount': soldCount,
      'mortalityRate': mortalityRate,
      'dateCreated': dateCreated,
      'status': status,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create BatchModel from Firestore document
  factory BatchModel.fromMap(String id, Map<String, dynamic> map) {
    return BatchModel(
      id: id,
      name: map['name'] ?? '',
      initialCount: map['initialCount'] ?? 0,
      liveCount: map['liveCount'] ?? 0,
      soldCount: map['soldCount'] ?? 0,
      mortalityRate: (map['mortalityRate'] ?? 0.0).toDouble(),
      dateCreated: (map['dateCreated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'active',
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create copy with changes
  BatchModel copyWith({
    String? id,
    String? name,
    int? initialCount,
    int? liveCount,
    int? soldCount,
    double? mortalityRate,
    DateTime? dateCreated,
    String? status,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BatchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initialCount: initialCount ?? this.initialCount,
      liveCount: liveCount ?? this.liveCount,
      soldCount: soldCount ?? this.soldCount,
      mortalityRate: mortalityRate ?? this.mortalityRate,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
