import 'package:cloud_firestore/cloud_firestore.dart';

class SaleRecordModel {
  final String id;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime soldAt;
  final String? notes;
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SaleRecordModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.soldAt,
    this.notes,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'soldAt': soldAt,
      'notes': notes,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  factory SaleRecordModel.fromMap(String id, Map<String, dynamic> map) {
    return SaleRecordModel(
      id: id,
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      soldAt: (map['soldAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'],
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  SaleRecordModel copyWith({
    String? id,
    String? itemName,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    DateTime? soldAt,
    String? notes,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleRecordModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      soldAt: soldAt ?? this.soldAt,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
