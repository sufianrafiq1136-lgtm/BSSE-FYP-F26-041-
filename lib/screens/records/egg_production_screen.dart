import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/egg_record_model.dart';
import '../../services/egg_production_service.dart';
import '../../theme/app_colors.dart';

class EggProductionScreen extends StatefulWidget {
  const EggProductionScreen({super.key});

  @override
  State<EggProductionScreen> createState() => _EggProductionScreenState();
}

class _EggProductionScreenState extends State<EggProductionScreen> {
  final EggProductionService _eggService = EggProductionService();
  DateTime _selectedDate = DateTime.now();

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
        title: const Text('Daily Egg Production'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _userId == null || _farmId == null
          ? const Center(child: Text('Please sign in to manage egg records.'))
          : Column(
              children: [
                _buildDateSelector(),
                _buildDailyTotal(),
                Expanded(child: _buildRecordList()),
              ],
            ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Date: ${_dateLabel(_selectedDate)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTotal() {
    return StreamBuilder<int>(
      stream: _eggService.streamDailyTotal(
        userId: _userId!,
        farmId: _farmId!,
        date: _selectedDate,
      ),
      builder: (context, snapshot) {
        final total = snapshot.data ?? 0;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Total Count',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                '$total eggs',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordList() {
    return StreamBuilder<List<EggRecordModel>>(
      stream: _eggService.streamRecordsForDate(
        userId: _userId!,
        farmId: _farmId!,
        date: _selectedDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load records: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Text(
              'No egg production records for this date.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('${record.eggCount} eggs'),
                subtitle: Text(record.notes ?? 'No notes'),
                trailing: IconButton(
                  onPressed: () async {
                    await _eggService.deleteEggRecord(
                      userId: _userId!,
                      farmId: _farmId!,
                      recordId: record.id,
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddRecordDialog() async {
    final formKey = GlobalKey<FormState>();
    final countController = TextEditingController();
    final notesController = TextEditingController();
    DateTime date = _selectedDate;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Egg Record'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: countController,
                        decoration: const InputDecoration(
                          labelText: 'Egg count',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => int.tryParse(value ?? '') == null
                            ? 'Enter valid count'
                            : null,
                      ),
                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_dateLabel(date)),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  date = picked;
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

                    final record = EggRecordModel(
                      id: '',
                      recordDate: date,
                      eggCount: int.parse(countController.text.trim()),
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );

                    await _eggService.addEggRecord(
                      userId: _userId!,
                      farmId: _farmId!,
                      record: record,
                    );

                    if (!mounted || !dialogContext.mounted) {
                      return;
                    }
                    setState(() {
                      _selectedDate = date;
                    });
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

    countController.dispose();
    notesController.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
