import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FeedOrder {
  final String orderNo;
  final String feedType;
  final String quantity;
  final String date;
  final String status;
  final bool isReceived;

  FeedOrder({
    required this.orderNo,
    required this.feedType,
    required this.quantity,
    required this.date,
    required this.status,
    required this.isReceived,
  });

  static List<FeedOrder> getSampleOrders() {
    return [
      FeedOrder(
        orderNo: '122',
        feedType: 'Feed Type',
        quantity: 'Quantity',
        date: '23rd December 2022',
        status: 'Received',
        isReceived: true,
      ),
      FeedOrder(
        orderNo: '123',
        feedType: 'Feed Type',
        quantity: 'Quantity',
        date: '23rd December 2022',
        status: 'Not Received',
        isReceived: false,
      ),
      FeedOrder(
        orderNo: '124',
        feedType: 'Feed Type',
        quantity: 'Quantity',
        date: '23rd December 2022',
        status: 'Not Received',
        isReceived: false,
      ),
      FeedOrder(
        orderNo: '125',
        feedType: 'Feed Type',
        quantity: 'Quantity',
        date: '23rd December 2022',
        status: 'Not Received',
        isReceived: false,
      ),
    ];
  }
}

class FeedManagementScreen extends StatefulWidget {
  const FeedManagementScreen({super.key});

  @override
  State<FeedManagementScreen> createState() => _FeedManagementScreenState();
}

class _FeedManagementScreenState extends State<FeedManagementScreen> {
  int _selectedTab = 1; // 0 = Inventory, 1 = Orders
  String _selectedDate = 'Select Date';
  String _selectedFeedType = 'Feed Type';
  final List<FeedOrder> _orders = FeedOrder.getSampleOrders();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Header with menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            
            // Tab toggle
            _buildTabToggle(),
            
            const SizedBox(height: 20),
            
            // Filters
            _buildFilters(),
            
            const SizedBox(height: 20),
            
            // Summary
            _buildSummary(),
            
            const Divider(height: 32),
            
            // Orders list
            Expanded(
              child: _selectedTab == 1 ? _buildOrdersList() : _buildInventoryPlaceholder(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new order
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new order')),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: _selectedTab == 0
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Inventory',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 0
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      'Orders',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 1
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          _buildFilterChip(_selectedDate, Icons.calendar_today, () {
            // TODO: Show date picker
          }),
          const SizedBox(width: 12),
          _buildFilterChip(_selectedFeedType, Icons.arrow_drop_down, () {
            // TODO: Show feed type picker
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Feed Order Value',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '-10,56,180',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Order Bags Quantity',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(FeedOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order No. ${order.orderNo}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.feedType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    order.quantity,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Text(
                '3,000',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Order Status: ${order.status}',
                style: TextStyle(
                  fontSize: 12,
                  color: order.isReceived ? Colors.green : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildInventoryPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Inventory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
