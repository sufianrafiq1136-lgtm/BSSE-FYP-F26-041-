import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            title: Text('Need help using the app?'),
            subtitle: Text('Email support@poultryfarm.app for assistance.'),
          ),
          Divider(),
          ListTile(
            title: Text('Common support topics'),
            subtitle: Text('Account, inventory sync, batch records, and notifications.'),
          ),
        ],
      ),
    );
  }
}