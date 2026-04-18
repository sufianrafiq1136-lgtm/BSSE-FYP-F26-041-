import '../models/batch_model.dart';
import 'firestore_service.dart';

class BatchService {
  static final BatchService _instance = BatchService._internal();

  factory BatchService() {
    return _instance;
  }

  BatchService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  /// Firestore collection path builder
  String _getBatchPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/batches';
  }

  /// Create a new batch
  Future<String> createBatch({
    required String userId,
    required String farmId,
    required BatchModel batch,
  }) async {
    try {
      final batchWithMetadata = batch.copyWith(
        userId: userId,
        farmId: farmId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docId = await _firestoreService.create(
        _getBatchPath(userId: userId, farmId: farmId),
        batchWithMetadata.toMap(),
      );

      print('✓ Batch created: $docId');
      return docId;
    } catch (e) {
      print('✗ Create batch error: $e');
      rethrow;
    }
  }

  /// Get a single batch
  Future<BatchModel?> getBatch({
    required String userId,
    required String farmId,
    required String batchId,
  }) async {
    try {
      final data = await _firestoreService.read(
        _getBatchPath(userId: userId, farmId: farmId),
        batchId,
      );

      if (data != null) {
        return BatchModel.fromMap(batchId, data);
      }
      return null;
    } catch (e) {
      print('✗ Get batch error: $e');
      rethrow;
    }
  }

  /// Get all batches for a farm
  Future<List<BatchModel>> getBatches({
    required String userId,
    required String farmId,
  }) async {
    try {
      final docs = await _firestoreService.readAll(
        _getBatchPath(userId: userId, farmId: farmId),
      );

      return docs
          .map((doc) => BatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get batches error: $e');
      rethrow;
    }
  }

  /// Get active batches only
  Future<List<BatchModel>> getActiveBatches({
    required String userId,
    required String farmId,
  }) async {
    try {
      final docs = await _firestoreService.readWhere(
        collectionPath: _getBatchPath(userId: userId, farmId: farmId),
        field: 'status',
        value: 'active',
      );

      return docs
          .map((doc) => BatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('✗ Get active batches error: $e');
      rethrow;
    }
  }

  /// Update a batch (mortality rate, sold count, etc)
  Future<void> updateBatch({
    required String userId,
    required String farmId,
    required String batchId,
    required BatchModel updatedBatch,
  }) async {
    try {
      await _firestoreService.update(
        _getBatchPath(userId: userId, farmId: farmId),
        batchId,
        updatedBatch.copyWith(updatedAt: DateTime.now()).toMap(),
      );

      print('✓ Batch updated: $batchId');
    } catch (e) {
      print('✗ Update batch error: $e');
      rethrow;
    }
  }

  /// Mark batch as completed
  Future<void> completeBatch({
    required String userId,
    required String farmId,
    required String batchId,
  }) async {
    try {
      final batch = await getBatch(
        userId: userId,
        farmId: farmId,
        batchId: batchId,
      );

      if (batch != null) {
        await updateBatch(
          userId: userId,
          farmId: farmId,
          batchId: batchId,
          updatedBatch: batch.copyWith(status: 'completed'),
        );
      }
    } catch (e) {
      print('✗ Complete batch error: $e');
      rethrow;
    }
  }

  /// Delete a batch
  Future<void> deleteBatch({
    required String userId,
    required String farmId,
    required String batchId,
  }) async {
    try {
      await _firestoreService.delete(
        _getBatchPath(userId: userId, farmId: farmId),
        batchId,
      );

      print('✓ Batch deleted: $batchId');
    } catch (e) {
      print('✗ Delete batch error: $e');
      rethrow;
    }
  }

  /// Stream all batches (real-time updates)
  Stream<List<BatchModel>> streamBatches({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getBatchPath(userId: userId, farmId: farmId))
        .map((docs) => docs
            .map((doc) => BatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream active batches only (real-time updates)
  Stream<List<BatchModel>> streamActiveBatches({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamWhere(
          collectionPath: _getBatchPath(userId: userId, farmId: farmId),
          field: 'status',
          value: 'active',
        )
        .map((docs) => docs
            .map((doc) => BatchModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Helper used by notification layer
  bool isHighMortality(BatchModel batch, {double threshold = 10.0}) {
    return batch.mortalityRate >= threshold;
  }
}
