import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/notification_preferences_service.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _lowFeedAlerts = true;
  bool _mortalityAlerts = true;
  bool _generalAlerts = true;
  bool _isLoading = true;
  bool _isSaving = false;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    if (_userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final prefs = await NotificationPreferencesService.getPreferences(_userId!);
      if (!mounted) return;
      setState(() {
        _lowFeedAlerts = prefs.lowFeedAlerts;
        _mortalityAlerts = prefs.mortalityAlerts;
        _generalAlerts = prefs.generalAlerts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notification settings.')),
      );
    }
  }

  Future<void> _savePreferences() async {
    if (_userId == null || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await NotificationPreferencesService.savePreferences(
        uid: _userId!,
        preferences: NotificationPreferences(
          lowFeedAlerts: _lowFeedAlerts,
          mortalityAlerts: _mortalityAlerts,
          generalAlerts: _generalAlerts,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification settings saved.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save notification settings.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: (_isLoading || _isSaving || _userId == null) ? null : _savePreferences,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userId == null
              ? const Center(
                  child: Text(
                    'Please sign in to manage notification settings.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSwitchTile(
                      title: 'Low Feed Alerts',
                      subtitle: 'Notify when feed quantity drops below threshold',
                      value: _lowFeedAlerts,
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => setState(() => _lowFeedAlerts = value),
                    ),
                    _buildSwitchTile(
                      title: 'Mortality Alerts',
                      subtitle: 'Notify when batch mortality crosses threshold',
                      value: _mortalityAlerts,
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => setState(() => _mortalityAlerts = value),
                    ),
                    _buildSwitchTile(
                      title: 'General Alerts',
                      subtitle: 'App updates and reminders',
                      value: _generalAlerts,
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => setState(() => _generalAlerts = value),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}