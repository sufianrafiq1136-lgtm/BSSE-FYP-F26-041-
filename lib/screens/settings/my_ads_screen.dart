import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AdItem {
  final String id;
  final String name;
  final String quantity;
  final String postedOn;
  final String status; // 'Sold' or 'Posted'
  final String imageUrl;

  AdItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.postedOn,
    required this.status,
    this.imageUrl = '',
  });

  static List<AdItem> getSampleAds() {
    return [
      AdItem(
        id: '1',
        name: 'Broiler',
        quantity: '',
        postedOn: '22/11/22',
        status: 'Sold',
        imageUrl: 'https://images.unsplash.com/photo-1612170153139-6f881ff067e0?w=200&q=80',
      ),
      AdItem(
        id: '2',
        name: 'Eggs',
        quantity: '',
        postedOn: '12/12/22',
        status: 'Sold',
        imageUrl: 'https://images.unsplash.com/photo-1569288052389-dac9b01c9c05?w=200&q=80',
      ),
      AdItem(
        id: '3',
        name: 'Deshi',
        quantity: '',
        postedOn: '13/01/23',
        status: 'Posted',
        imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=200&q=80',
      ),
    ];
  }
}

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  final List<AdItem> _ads = AdItem.getSampleAds();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'My Ads',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Ads list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _ads.length,
                itemBuilder: (context, index) {
                  return _buildAdCard(_ads[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard(AdItem ad) {
    final isSold = ad.status == 'Sold';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 70,
              height: 70,
              color: AppColors.inputBackground,
              child: ad.imageUrl.isNotEmpty
                  ? Image.network(
                      ad.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: AppColors.textSecondary,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ad.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSold ? Colors.green : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ad.status,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty.:${ad.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted On: ${ad.postedOn}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
