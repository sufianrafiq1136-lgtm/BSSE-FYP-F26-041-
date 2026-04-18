import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/batch_model.dart';
import '../../services/batch_service.dart';
import '../../theme/app_colors.dart';
import 'add_batch_screen.dart';

class BatchDetailsScreen extends StatefulWidget {
  final String? batchId;

  const BatchDetailsScreen({super.key, this.batchId});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  final BatchService _batchService = BatchService();
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.attach_money, 'title': 'Income'},
    {'icon': Icons.money_off, 'title': 'Expenses'},
    {'icon': Icons.restaurant, 'title': 'Feed Served'},
    {'icon': Icons.warning_amber_outlined, 'title': 'Mortality'},
    {'icon': Icons.monitor_weight_outlined, 'title': 'Body Weight'},
    {'icon': Icons.inventory_2_outlined, 'title': 'Stocks'},
    {'icon': Icons.vaccines_outlined, 'title': 'Vaccination'},
    {'icon': Icons.medical_services_outlined, 'title': 'Medicine'},
  ];

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  String? get _farmId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: _userId == null || _farmId == null || widget.batchId == null
                  ? const Center(
                      child: Text(
                        'Please sign in to view batch details.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : StreamBuilder<List<BatchModel>>(
                      stream: _batchService.streamBatches(
                        userId: _userId!,
                        farmId: _farmId!,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Failed to load batch: ${snapshot.error}'),
                          );
                        }

                        final batches = snapshot.data ?? [];
                        final batch = batches.where((item) => item.id == widget.batchId).isNotEmpty
                            ? batches.firstWhere((item) => item.id == widget.batchId)
                            : null;

                        if (batch == null) {
                          return const Center(
                            child: Text(
                              'Batch not found.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            _buildBatchInfoCard(batch),
                            const SizedBox(height: 20),
                            _buildTabPills(),
                            const SizedBox(height: 16),
                            Expanded(child: _buildMenuList(batch)),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await _openEditor();
              } else if (value == 'complete') {
                await _batchService.completeBatch(
                  userId: _userId!,
                  farmId: _farmId!,
                  batchId: widget.batchId!,
                );
              } else if (value == 'delete') {
                await _deleteBatch();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'complete', child: Text('Mark Complete')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatchInfoCard(BatchModel batch) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildActionIcon(Icons.person_outline),
                    const SizedBox(width: 8),
                    _buildActionIcon(Icons.edit_outlined, onTap: () => _openEditor()),
                    const SizedBox(width: 8),
                    _buildActionIcon(Icons.close, onTap: () => _deleteBatch()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              batch.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${batch.getAgeInDays()} days old • ${batch.status}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildStatItem('Total', '${batch.initialCount}', AppColors.primary),
                _buildStatItem('Sold', '${batch.soldCount}', AppColors.textSecondary),
                _buildStatItem('Mortality', '${batch.mortalityRate.toStringAsFixed(1)}%', Colors.red),
                _buildStatItem('Live', '${batch.liveCount}', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTabPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildTabPill(0, 'Records'),
          const SizedBox(width: 12),
          _buildTabPill(1, 'Analysis'),
          const SizedBox(width: 12),
          _buildTabPill(2, 'Reports'),
        ],
      ),
    );
  }

  Widget _buildTabPill(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList(BatchModel batch) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildMenuItem(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item['title']} for ${batch.name}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor() async {
    if (widget.batchId == null) {
      return;
    }

    final batches = await _batchService.getBatches(
      userId: _userId!,
      farmId: _farmId!,
    );
    final batch = batches.where((item) => item.id == widget.batchId).isNotEmpty
        ? batches.firstWhere((item) => item.id == widget.batchId)
        : null;

    if (batch == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBatchScreen(existingBatch: batch),
      ),
    );
  }

  Future<void> _deleteBatch() async {
    if (_userId == null || _farmId == null || widget.batchId == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('Delete this batch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _batchService.deleteBatch(
        userId: _userId!,
        farmId: _farmId!,
        batchId: widget.batchId!,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}