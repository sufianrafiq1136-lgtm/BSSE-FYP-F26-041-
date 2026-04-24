import 'package:cloud_firestore/cloud_firestore.dart';

class EggRecordModel {
  final String id;
  final DateTime recordDate;
  final int eggCount;
  final String? notes;
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EggRecordModel({
    required this.id,
    required this.recordDate,
    required this.eggCount,
    this.notes,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordDate': recordDate,
      'eggCount': eggCount,
      'notes': notes,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  factory EggRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return EggRecordModel(
      id: id,
      recordDate: (map['recordDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eggCount: map['eggCount'] ?? 0,
      notes: map['notes'],
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  EggRecordModel copyWith({
    String? id,
    DateTime? recordDate,
    int? eggCount,
    String? notes,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EggRecordModel(
      id: id ?? this.id,
      recordDate: recordDate ?? this.recordDate,
      eggCount: eggCount ?? this.eggCount,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
