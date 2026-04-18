import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/batch_model.dart';
import '../../services/batch_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddBatchScreen extends StatefulWidget {
  final BatchModel? existingBatch;

  const AddBatchScreen({super.key, this.existingBatch});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchNameController = TextEditingController();
  final _initialCountController = TextEditingController();
  final _liveCountController = TextEditingController();
  final _soldCountController = TextEditingController();
  final _mortalityRateController = TextEditingController();
  final BatchService _batchService = BatchService();

  DateTime _startDate = DateTime.now();
  String _status = 'active';
  bool _isLoading = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    final batch = widget.existingBatch;
    if (batch != null) {
      _batchNameController.text = batch.name;
      _initialCountController.text = batch.initialCount.toString();
      _liveCountController.text = batch.liveCount.toString();
      _soldCountController.text = batch.soldCount.toString();
      _mortalityRateController.text = batch.mortalityRate.toString();
      _startDate = batch.dateCreated;
      _status = batch.status;
    }
  }

  @override
  void dispose() {
    _batchNameController.dispose();
    _initialCountController.dispose();
    _liveCountController.dispose();
    _soldCountController.dispose();
    _mortalityRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final batch = BatchModel(
        id: widget.existingBatch?.id ?? '',
        name: _batchNameController.text.trim(),
        initialCount: int.parse(_initialCountController.text.trim()),
        liveCount: int.parse(_liveCountController.text.trim()),
        soldCount: int.parse(_soldCountController.text.trim()),
        mortalityRate: double.parse(_mortalityRateController.text.trim()),
        dateCreated: _startDate,
        status: _status,
      );

      if (widget.existingBatch == null) {
        await _batchService.createBatch(
          userId: _userId!,
          farmId: _userId!,
          batch: batch,
        );
      } else {
        await _batchService.updateBatch(
          userId: _userId!,
          farmId: _userId!,
          batchId: widget.existingBatch!.id,
          updatedBatch: batch,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingBatch == null ? 'Batch added successfully' : 'Batch updated successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Batch Name'),
                      CustomTextField(
                        controller: _batchNameController,
                        hintText: 'Enter batch name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter batch name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Initial Count'),
                      CustomTextField(
                        controller: _initialCountController,
                        hintText: 'Enter initial bird count',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter count';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Live Count'),
                      CustomTextField(
                        controller: _liveCountController,
                        hintText: 'Enter live bird count',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter live count';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Sold Count'),
                      CustomTextField(
                        controller: _soldCountController,
                        hintText: 'Enter sold bird count',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter sold count';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Mortality Rate (%)'),
                      CustomTextField(
                        controller: _mortalityRateController,
                        hintText: 'Enter mortality rate',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter mortality rate';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Start Date'),
                      _buildDatePicker(),
                      const SizedBox(height: 20),
                      _buildLabel('Status'),
                      _buildDropdown(),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: widget.existingBatch == null ? 'Add Batch' : 'Update Batch',
                        isLoading: _isLoading,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            widget.existingBatch == null ? 'Add New Batch' : 'Edit Batch',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
            const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          items: const [
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'archived', child: Text('Archived')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _status = value);
            }
          },
        ),
      ),
    );
  }
}