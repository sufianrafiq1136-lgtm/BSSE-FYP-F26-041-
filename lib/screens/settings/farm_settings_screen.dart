import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../settings/my_ads_screen.dart';

class FarmSettingsScreen extends StatelessWidget {
  const FarmSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsItems = [
      {'icon': Icons.campaign_outlined, 'title': 'My Ads', 'screen': const MyAdsScreen()},
      {'icon': Icons.person_outline, 'title': 'Profile', 'screen': null},
      {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'screen': null},
      {'icon': Icons.help_outline, 'title': 'Help & Support', 'screen': null},
      {'icon': Icons.info_outline, 'title': 'About', 'screen': null},
      {'icon': Icons.logout, 'title': 'Logout', 'screen': null},
    ];

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
                  const Text(
                    'Farm Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: settingsItems.length,
                itemBuilder: (context, index) {
                  final item = settingsItems[index];
                  return _buildSettingsItem(
                    context: context,
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    screen: item['screen'] as Widget?,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? screen,
  }) {
    return InkWell(
      onTap: () {
        if (title == 'Logout') {
          _showLogoutDialog(context);
        } else if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon!')),
          );
        }
      },
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
                color: title == 'Logout' ? Colors.red : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: title == 'Logout' ? Colors.red : AppColors.textPrimary,
                ),
              ),
            ),
            if (title != 'Logout')
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
