import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BatchDetailsScreen extends StatefulWidget {
  final String? batchId;
  
  const BatchDetailsScreen({super.key, this.batchId});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  int _selectedTab = 0; // 0 = Records, 1 = Analysis, 2 = Reports

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Header
            _buildHeader(),
            
            const SizedBox(height: 20),
            
            // Batch Info Card
            _buildBatchInfoCard(),
            
            const SizedBox(height: 20),
            
            // Tab Pills
            _buildTabPills(),
            
            const SizedBox(height: 16),
            
            // Menu Items
            Expanded(
              child: _buildMenuList(),
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchInfoCard() {
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
                      'Batch Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1 week: 5 days',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildActionIcon(Icons.person_outline),
                    const SizedBox(width: 8),
                    _buildActionIcon(Icons.edit_outlined),
                    const SizedBox(width: 8),
                    _buildActionIcon(Icons.close),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem('Total Chicks:', '1100', AppColors.primary),
                const SizedBox(width: 16),
                _buildStatItem('Sold:', '1000', AppColors.textSecondary),
                const SizedBox(width: 16),
                _buildStatItem('Mortality:', '0', AppColors.textSecondary),
                const SizedBox(width: 16),
                _buildStatItem('Live:', '100', AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
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
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
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
          border: isSelected 
              ? null 
              : Border.all(color: AppColors.border),
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

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _menuItems.length,
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        return _buildMenuItem(
          icon: item['icon'] as IconData,
          title: item['title'] as String,
          onTap: () {
            // TODO: Navigate to respective screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item['title']} clicked')),
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
}
