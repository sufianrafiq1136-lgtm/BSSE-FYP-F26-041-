import '../models/poultry_item_model.dart';
import 'firestore_service.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();

  factory InventoryService() {
    return _instance;
  }

  InventoryService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  /// Firestore collection path builder
  String _getInventoryPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/inventory';
  }

  /// Add a new poultry item
  Future<String> addPoultryItem({
    required String userId,
    required String farmId,
    required PoultryItem item,
  }) async {
    try {
      final itemWithMetadata = item.copyWith(
        userId: userId,
        farmId: farmId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docId = await _firestoreService.create(
        _getInventoryPath(userId: userId, farmId: farmId),
        itemWithMetadata.toMap(),
      );

      print('✓ Poultry item added: $docId');
      return docId;
    } catch (e) {
      print('✗ Add poultry item error: $e');
      rethrow;
    }
  }

  /// Get a single poultry item
  Future<PoultryItem?> getPoultryItem({
    required String userId,
    required String farmId,
    required String itemId,
  }) async {
    try {
      final data = await _firestoreService.read(
        _getInventoryPath(userId: userId, farmId: farmId),
        itemId,
      );

      if (data != null) {
        return PoultryItem.fromMap(itemId, data);
      }
      return null;
    } catch (e) {
      print('✗ Get poultry item error: $e');
      rethrow;
    }
  }

  /// Get all poultry items for a farm
  Future<List<PoultryItem>> getInventory({
    required String userId,
    required String farmId,
  }) async {
    try {
      final docs = await _firestoreService.readAll(
        _getInventoryPath(userId: userId, farmId: farmId),
      );

      return docs
          .map((doc) => PoultryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get inventory error: $e');
      rethrow;
    }
  }

  /// Get poultry items filtered by category
  Future<List<PoultryItem>> getInventoryByCategory({
    required String userId,
    required String farmId,
    required String category,
  }) async {
    try {
      final docs = await _firestoreService.readWhere(
        collectionPath: _getInventoryPath(userId: userId, farmId: farmId),
        field: 'category',
        value: category,
      );

      return docs
          .map((doc) => PoultryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get inventory by category error: $e');
      rethrow;
    }
  }

  /// Update a poultry item
  Future<void> updatePoultryItem({
    required String userId,
    required String farmId,
    required String itemId,
    required PoultryItem updatedItem,
  }) async {
    try {
      await _firestoreService.update(
        _getInventoryPath(userId: userId, farmId: farmId),
        itemId,
        updatedItem.copyWith(updatedAt: DateTime.now()).toMap(),
      );

      print('✓ Poultry item updated: $itemId');
    } catch (e) {
      print('✗ Update poultry item error: $e');
      rethrow;
    }
  }

  /// Delete a poultry item
  Future<void> deletePoultryItem({
    required String userId,
    required String farmId,
    required String itemId,
  }) async {
    try {
      await _firestoreService.delete(
        _getInventoryPath(userId: userId, farmId: farmId),
        itemId,
      );

      print('✓ Poultry item deleted: $itemId');
    } catch (e) {
      print('✗ Delete poultry item error: $e');
      rethrow;
    }
  }

  /// Stream all poultry items (real-time updates)
  Stream<List<PoultryItem>> streamInventory({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getInventoryPath(userId: userId, farmId: farmId))
        .map((docs) => docs
            .map((doc) => PoultryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream poultry items filtered by category (real-time updates)
  Stream<List<PoultryItem>> streamInventoryByCategory({
    required String userId,
    required String farmId,
    required String category,
  }) {
    return _firestoreService
        .streamWhere(
          collectionPath: _getInventoryPath(userId: userId, farmId: farmId),
          field: 'category',
          value: category,
        )
        .map((docs) => docs
            .map((doc) => PoultryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}
