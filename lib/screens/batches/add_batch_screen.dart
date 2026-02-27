import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddBatchScreen extends StatefulWidget {
  const AddBatchScreen({super.key});

  @override
  State<AddBatchScreen> createState() => _AddBatchScreenState();
}

class _AddBatchScreenState extends State<AddBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchNameController = TextEditingController();
  final _totalChicksController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _supplierController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  String _birdType = 'Broiler';
  bool _isLoading = false;

  final List<String> _birdTypes = ['Broiler', 'Layer', 'Desi', 'Duck', 'Other'];

  @override
  void dispose() {
    _batchNameController.dispose();
    _totalChicksController.dispose();
    _purchasePriceController.dispose();
    _supplierController.dispose();
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
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate saving
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => _isLoading = false);
        
        // Return the new batch data
        Navigator.pop(context, {
          'name': _batchNameController.text,
          'totalChicks': int.parse(_totalChicksController.text),
          'birdType': _birdType,
          'startDate': _startDate,
          'purchasePrice': _purchasePriceController.text,
          'supplier': _supplierController.text,
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Batch added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batch Name
                      _buildLabel('Batch Name'),
                      CustomTextField(
                        controller: _batchNameController,
                        hintText: 'Enter batch name (e.g., Batch A)',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter batch name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Bird Type Dropdown
                      _buildLabel('Bird Type'),
                      _buildDropdown(),
                      
                      const SizedBox(height: 20),
                      
                      // Total Chicks
                      _buildLabel('Total Chicks'),
                      CustomTextField(
                        controller: _totalChicksController,
                        hintText: 'Enter total number of chicks',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter total chicks';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Start Date
                      _buildLabel('Start Date'),
                      _buildDatePicker(),
                      
                      const SizedBox(height: 20),
                      
                      // Purchase Price
                      _buildLabel('Purchase Price (per chick)'),
                      CustomTextField(
                        controller: _purchasePriceController,
                        hintText: 'Enter price per chick',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter purchase price';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Supplier
                      _buildLabel('Supplier (Optional)'),
                      CustomTextField(
                        controller: _supplierController,
                        hintText: 'Enter supplier name',
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Submit Button
                      PrimaryButton(
                        text: 'Add Batch',
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
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Add New Batch',
            style: TextStyle(
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _birdType,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          items: _birdTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _birdType = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
