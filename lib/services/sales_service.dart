import '../models/sale_record_model.dart';
import 'firestore_service.dart';

class SalesService {
  static final SalesService _instance = SalesService._internal();

  factory SalesService() {
    return _instance;
  }

  SalesService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  String _getSalesPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/sales';
  }

  Future<String> addSaleRecord({
    required String userId,
    required String farmId,
    required SaleRecordModel sale,
  }) async {
    final saleWithMetadata = sale.copyWith(
      userId: userId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _firestoreService.create(
      _getSalesPath(userId: userId, farmId: farmId),
      saleWithMetadata.toMap(),
    );
  }

  Future<void> deleteSaleRecord({
    required String userId,
    required String farmId,
    required String saleId,
  }) async {
    await _firestoreService.delete(
      _getSalesPath(userId: userId, farmId: farmId),
      saleId,
    );
  }

  Stream<List<SaleRecordModel>> streamSales({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getSalesPath(userId: userId, farmId: farmId))
        .map((docs) {
          final sales = docs
              .map(
                (doc) => SaleRecordModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          sales.sort((a, b) => b.soldAt.compareTo(a.soldAt));
          return sales;
        });
  }

  Stream<List<SaleRecordModel>> streamMonthlySales({
    required String userId,
    required String farmId,
    required DateTime month,
  }) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);

    return streamSales(userId: userId, farmId: farmId).map(
      (sales) => sales
          .where(
            (sale) =>
                !sale.soldAt.isBefore(monthStart) &&
                sale.soldAt.isBefore(monthEnd),
          )
          .toList(),
    );
  }

  Stream<double> streamMonthlyTotal({
    required String userId,
    required String farmId,
    required DateTime month,
  }) {
    return streamMonthlySales(userId: userId, farmId: farmId, month: month).map(
      (sales) => sales.fold<double>(0, (sum, sale) => sum + sale.totalAmount),
    );
  }
}
