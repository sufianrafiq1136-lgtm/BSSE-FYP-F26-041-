import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/sale_record_model.dart';
import '../../services/sales_service.dart';
import '../../theme/app_colors.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SalesService _salesService = SalesService();
  final DateTime _currentMonth = DateTime.now();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  String? get _farmId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Monthly Sales'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSaleDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _userId == null || _farmId == null
          ? const Center(child: Text('Please sign in to manage sales.'))
          : Column(
              children: [
                _buildMonthlyTotalCard(),
                Expanded(child: _buildSalesList()),
              ],
            ),
    );
  }

  Widget _buildMonthlyTotalCard() {
    return StreamBuilder<double>(
      stream: _salesService.streamMonthlyTotal(
        userId: _userId!,
        farmId: _farmId!,
        month: _currentMonth,
      ),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0.0;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Sale (${_monthLabel(_currentMonth)})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    total.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.trending_up, color: Colors.green, size: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesList() {
    return StreamBuilder<List<SaleRecordModel>>(
      stream: _salesService.streamMonthlySales(
        userId: _userId!,
        farmId: _farmId!,
        month: _currentMonth,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Failed to load sales: ${snapshot.error}'));
        }

        final sales = snapshot.data ?? [];
        if (sales.isEmpty) {
          return const Center(
            child: Text(
              'No sales for this month yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(sale.itemName),
                subtitle: Text(
                  '${_dateLabel(sale.soldAt)}   Qty: ${sale.quantity} x ${sale.unitPrice.toStringAsFixed(2)}',
                ),
                trailing: Text(
                  sale.totalAmount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddSaleDialog() async {
    final formKey = GlobalKey<FormState>();
    final itemController = TextEditingController();
    final quantityController = TextEditingController();
    final unitPriceController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Sale'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: itemController,
                        decoration: const InputDecoration(
                          labelText: 'Item name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter item name'
                            : null,
                      ),
                      TextFormField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => int.tryParse(value ?? '') == null
                            ? 'Enter valid quantity'
                            : null,
                      ),
                      TextFormField(
                        controller: unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit price',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            double.tryParse(value ?? '') == null
                            ? 'Enter valid price'
                            : null,
                      ),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_dateLabel(selectedDate)),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Text('Pick Date'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final qty = int.parse(quantityController.text.trim());
                    final unitPrice = double.parse(
                      unitPriceController.text.trim(),
                    );
                    final total = qty * unitPrice;

                    final sale = SaleRecordModel(
                      id: '',
                      itemName: itemController.text.trim(),
                      quantity: qty,
                      unitPrice: unitPrice,
                      totalAmount: total,
                      soldAt: selectedDate,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );

                    await _salesService.addSaleRecord(
                      userId: _userId!,
                      farmId: _farmId!,
                      sale: sale,
                    );

                    if (!mounted || !dialogContext.mounted) {
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    itemController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    notesController.dispose();
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _dateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
