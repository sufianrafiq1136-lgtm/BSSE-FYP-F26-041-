import '../models/feed_model.dart';
import 'firestore_service.dart';

class FeedService {
  static final FeedService _instance = FeedService._internal();

  factory FeedService() {
    return _instance;
  }

  FeedService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  /// Firestore collection path builder
  String _getFeedPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/feed';
  }

  /// Add a new feed item
  Future<String> addFeedItem({
    required String userId,
    required String farmId,
    required FeedModel feed,
  }) async {
    try {
      final feedWithMetadata = feed.copyWith(
        userId: userId,
        farmId: farmId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docId = await _firestoreService.create(
        _getFeedPath(userId: userId, farmId: farmId),
        feedWithMetadata.toMap(),
      );

      print('✓ Feed item added: $docId');
      return docId;
    } catch (e) {
      print('✗ Add feed item error: $e');
      rethrow;
    }
  }

  /// Get a single feed item
  Future<FeedModel?> getFeedItem({
    required String userId,
    required String farmId,
    required String feedId,
  }) async {
    try {
      final data = await _firestoreService.read(
        _getFeedPath(userId: userId, farmId: farmId),
        feedId,
      );

      if (data != null) {
        return FeedModel.fromMap(feedId, data);
      }
      return null;
    } catch (e) {
      print('✗ Get feed item error: $e');
      rethrow;
    }
  }

  /// Get all feed items for a farm
  Future<List<FeedModel>> getFeed({
    required String userId,
    required String farmId,
  }) async {
    try {
      final docs = await _firestoreService.readAll(
        _getFeedPath(userId: userId, farmId: farmId),
      );

      return docs
          .map((doc) => FeedModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get feed error: $e');
      rethrow;
    }
  }

  /// Get feed items by supplier
  Future<List<FeedModel>> getFeedBySupplier({
    required String userId,
    required String farmId,
    required String supplier,
  }) async {
    try {
      final docs = await _firestoreService.readWhere(
        collectionPath: _getFeedPath(userId: userId, farmId: farmId),
        field: 'supplier',
        value: supplier,
      );

      return docs
          .map((doc) => FeedModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get feed by supplier error: $e');
      rethrow;
    }
  }

  /// Update a feed item
  Future<void> updateFeedItem({
    required String userId,
    required String farmId,
    required String feedId,
    required FeedModel updatedFeed,
  }) async {
    try {
      await _firestoreService.update(
        _getFeedPath(userId: userId, farmId: farmId),
        feedId,
        updatedFeed.copyWith(updatedAt: DateTime.now()).toMap(),
      );

      print('✓ Feed item updated: $feedId');
    } catch (e) {
      print('✗ Update feed item error: $e');
      rethrow;
    }
  }

  /// Delete a feed item
  Future<void> deleteFeedItem({
    required String userId,
    required String farmId,
    required String feedId,
  }) async {
    try {
      await _firestoreService.delete(
        _getFeedPath(userId: userId, farmId: farmId),
        feedId,
      );

      print('✓ Feed item deleted: $feedId');
    } catch (e) {
      print('✗ Delete feed item error: $e');
      rethrow;
    }
  }

  /// Stream all feed items (real-time updates)
  Stream<List<FeedModel>> streamFeed({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getFeedPath(userId: userId, farmId: farmId))
        .map((docs) => docs
            .map((doc) => FeedModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream feed items by supplier (real-time updates)
  Stream<List<FeedModel>> streamFeedBySupplier({
    required String userId,
    required String farmId,
    required String supplier,
  }) {
    return _firestoreService
        .streamWhere(
          collectionPath: _getFeedPath(userId: userId, farmId: farmId),
          field: 'supplier',
          value: supplier,
        )
        .map((docs) => docs
            .map((doc) => FeedModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Helper used by notification layer
  bool isLowStock(FeedModel feed, {double threshold = 10.0}) {
    return feed.quantity < threshold;
  }
}
