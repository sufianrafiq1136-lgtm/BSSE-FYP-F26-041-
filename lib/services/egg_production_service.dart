import '../models/egg_record_model.dart';
import 'firestore_service.dart';

class EggProductionService {
  static final EggProductionService _instance =
      EggProductionService._internal();

  factory EggProductionService() {
    return _instance;
  }

  EggProductionService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  String _getEggPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/eggProduction';
  }

  Future<String> addEggRecord({
    required String userId,
    required String farmId,
    required EggRecordModel record,
  }) async {
    final recordWithMetadata = record.copyWith(
      userId: userId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _firestoreService.create(
      _getEggPath(userId: userId, farmId: farmId),
      recordWithMetadata.toMap(),
    );
  }

  Future<void> deleteEggRecord({
    required String userId,
    required String farmId,
    required String recordId,
  }) async {
    await _firestoreService.delete(
      _getEggPath(userId: userId, farmId: farmId),
      recordId,
    );
  }

  Stream<List<EggRecordModel>> streamEggRecords({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getEggPath(userId: userId, farmId: farmId))
        .map((docs) {
          final records = docs
              .map(
                (doc) => EggRecordModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          records.sort((a, b) => b.recordDate.compareTo(a.recordDate));
          return records;
        });
  }

  Stream<List<EggRecordModel>> streamRecordsForDate({
    required String userId,
    required String farmId,
    required DateTime date,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return streamEggRecords(userId: userId, farmId: farmId).map(
      (records) => records
          .where(
            (record) =>
                !record.recordDate.isBefore(dayStart) &&
                record.recordDate.isBefore(dayEnd),
          )
          .toList(),
    );
  }

  Stream<int> streamDailyTotal({
    required String userId,
    required String farmId,
    required DateTime date,
  }) {
    return streamRecordsForDate(userId: userId, farmId: farmId, date: date).map(
      (records) => records.fold<int>(0, (sum, record) => sum + record.eggCount),
    );
  }
}
