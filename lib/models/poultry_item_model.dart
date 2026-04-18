import 'package:cloud_firestore/cloud_firestore.dart';

class PoultryItem {
  final String id;
  final String name;
  final String quantity;
  final String location;
  final String imageUrl;
  final String category;
  final String? userId;
  final String? farmId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PoultryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.location,
    this.imageUrl = '',
    required this.category,
    this.userId,
    this.farmId,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert PoultryItem to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'location': location,
      'imageUrl': imageUrl,
      'category': category,
      'userId': userId,
      'farmId': farmId,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create PoultryItem from Firestore document
  factory PoultryItem.fromMap(String id, Map<String, dynamic> map) {
    return PoultryItem(
      id: id,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'],
      farmId: map['farmId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Create copy with changes
  PoultryItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? location,
    String? imageUrl,
    String? category,
    String? userId,
    String? farmId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoultryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      farmId: farmId ?? this.farmId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<PoultryItem> getSampleItems() {
    return [
      PoultryItem(
        id: '1',
        name: 'Broiler Chickens',
        quantity: '500 birds',
        location: 'Farm A',
        category: 'Birds',
        imageUrl: 'https://images.unsplash.com/photo-1612170153139-6f881ff067e0?w=400&q=80',
      ),
      PoultryItem(
        id: '2',
        name: 'Layer Eggs',
        quantity: '2000 eggs',
        location: 'Farm B',
        category: 'Eggs',
        imageUrl: 'https://images.unsplash.com/photo-1569288052389-dac9b01c9c05?w=400&q=80',
      ),
      PoultryItem(
        id: '3',
        name: 'Day-old Chicks',
        quantity: '300 chicks',
        location: 'Farm A',
        category: 'Chicks',
        imageUrl: 'https://images.unsplash.com/photo-1589923188651-268a9765e432?w=400&q=80',
      ),
      PoultryItem(
        id: '4',
        name: 'Desi Chickens',
        quantity: '150 birds',
        location: 'Farm C',
        category: 'Birds',
        imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=400&q=80',
      ),
    ];
  }
}
