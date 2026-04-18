import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/feed_model.dart';
import '../../services/feed_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddFeedScreen extends StatefulWidget {
  final FeedModel? existingFeed;

  const AddFeedScreen({super.key, this.existingFeed});

  @override
  State<AddFeedScreen> createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  final FeedService _feedService = FeedService();

  DateTime _nextSchedule = DateTime.now();
  bool _isLoading = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    final feed = widget.existingFeed;
    if (feed != null) {
      _nameController.text = feed.name;
      _quantityController.text = feed.quantity.toString();
      _costController.text = feed.cost.toString();
      _supplierController.text = feed.supplier ?? '';
      _notesController.text = feed.notes ?? '';
      _nextSchedule = feed.nextSchedule;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextSchedule,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      setState(() => _nextSchedule = picked);
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
      final feed = FeedModel(
        id: widget.existingFeed?.id ?? '',
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        nextSchedule: _nextSchedule,
        cost: double.parse(_costController.text.trim()),
        supplier: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (widget.existingFeed == null) {
        await _feedService.addFeedItem(
          userId: _userId!,
          farmId: _userId!,
          feed: feed,
        );
      } else {
        await _feedService.updateFeedItem(
          userId: _userId!,
          farmId: _userId!,
          feedId: widget.existingFeed!.id,
          updatedFeed: feed,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingFeed == null ? 'Feed added successfully' : 'Feed updated successfully'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(widget.existingFeed == null ? 'Add Feed' : 'Edit Feed'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: 'Feed name',
                validator: (value) => value == null || value.isEmpty ? 'Enter feed name' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _quantityController,
                hintText: 'Quantity in kg',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _costController,
                hintText: 'Cost',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _supplierController,
                hintText: 'Supplier (optional)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                hintText: 'Notes (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
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
                        '${_nextSchedule.year}-${_nextSchedule.month.toString().padLeft(2, '0')}-${_nextSchedule.day.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: widget.existingFeed == null ? 'Save Feed' : 'Update Feed',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}