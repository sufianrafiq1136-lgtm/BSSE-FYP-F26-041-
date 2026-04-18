import 'package:cloud_firestore/cloud_firestore.dart';

/// Base Firestore service for generic CRUD operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a document in a collection
  Future<String> create(String collectionPath, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _db.collection(collectionPath).add(data);
      print('✓ Document created: $collectionPath/${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('✗ Create error: $e');
      rethrow;
    }
  }

  /// Read a single document
  Future<Map<String, dynamic>?> read(
    String collectionPath,
    String documentId,
  ) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(collectionPath).doc(documentId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('✗ Read error: $e');
      rethrow;
    }
  }

  /// Read all documents in a collection
  Future<List<QueryDocumentSnapshot>> readAll(String collectionPath) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection(collectionPath).get();
      return querySnapshot.docs;
    } catch (e) {
      print('✗ ReadAll error: $e');
      rethrow;
    }
  }

  /// Read all documents with a query filter
  Future<List<QueryDocumentSnapshot>> readWhere({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print('✗ ReadWhere error: $e');
      rethrow;
    }
  }

  /// Update a document
  Future<void> update(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(documentId)
          .update({
        ...data,
        'updatedAt': DateTime.now(),
      });
      print('✓ Document updated: $collectionPath/$documentId');
    } catch (e) {
      print('✗ Update error: $e');
      rethrow;
    }
  }

  /// Delete a document
  Future<void> delete(String collectionPath, String documentId) async {
    try {
      await _db.collection(collectionPath).doc(documentId).delete();
      print('✓ Document deleted: $collectionPath/$documentId');
    } catch (e) {
      print('✗ Delete error: $e');
      rethrow;
    }
  }

  /// Stream of all documents in a collection (real-time updates)
  Stream<List<QueryDocumentSnapshot>> streamAll(String collectionPath) {
    return _db.collection(collectionPath).snapshots().map(
      (snapshot) {
        return snapshot.docs;
      },
    );
  }

  /// Stream of documents with a query filter (real-time updates)
  Stream<List<QueryDocumentSnapshot>> streamWhere({
    required String collectionPath,
    required String field,
    required dynamic value,
  }) {
    return _db
        .collection(collectionPath)
        .where(field, isEqualTo: value)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs,
        );
  }

  /// Batch write operations
  Future<void> batch(List<Function(WriteBatch)> operations) async {
    WriteBatch batch = _db.batch();
    for (var operation in operations) {
      operation(batch);
    }
    await batch.commit();
    print('✓ Batch write completed');
  }
}
