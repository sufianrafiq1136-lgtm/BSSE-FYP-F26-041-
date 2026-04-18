import 'package:cloud_firestore/cloud_firestore.dart';

class FeedModel {
  final String id;
  final String name;
  final double quantity; // in kg
  final DateTime nextSchedule;
  final double cost;
  final String? supplier;
  final String? notes;
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeedModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.nextSchedule,
    required this.cost,
    this.supplier,
    this.notes,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert FeedModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'nextSchedule': nextSchedule,
      'cost': cost,
      'supplier': supplier,
      'notes': notes,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create FeedModel from Firestore document
  factory FeedModel.fromMap(String id, Map<String, dynamic> map) {
    return FeedModel(
      id: id,
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      nextSchedule: (map['nextSchedule'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      supplier: map['supplier'],
      notes: map['notes'],
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create copy with changes
  FeedModel copyWith({
    String? id,
    String? name,
    double? quantity,
    DateTime? nextSchedule,
    double? cost,
    String? supplier,
    String? notes,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      nextSchedule: nextSchedule ?? this.nextSchedule,
      cost: cost ?? this.cost,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
