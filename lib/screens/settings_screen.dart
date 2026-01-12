import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled =
          prefs.getBool(AppConstants.notificationsKey) ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notificationsKey, value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _openTerms() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(AppConstants.termsOfUseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacy() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    Share.share(
      'Check out ${AppConstants.brandName} - ${AppConstants.brandDescription}',
    );
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all items and reset your saved amount to \$0.00. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = await StorageService.getInstance();
      await storage.saveItems([]);
      await storage.setSavedAmount(0.0);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.firstEntryKey, false);
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Row(
                        children: [
                          Icon(
                            CupertinoIcons.back,
                            color: AppColors.white,
                            size: 24,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 17,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: CupertinoIcons.doc_text,
                      title: 'Terms of Use',
                      onTap: _openTerms,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      icon: CupertinoIcons.shield,
                      title: 'Privacy Policy',
                      onTap: _openPrivacy,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      icon: CupertinoIcons.share,
                      title: 'Share App',
                      onTap: _shareApp,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.bell_fill,
                            color: AppColors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _notificationsEnabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: _toggleNotifications,
                          ),
                        ],
                      ),
                    ),
                    if (AppConstants.isDebug) ...[
                      const SizedBox(height: 24),
                      _buildSettingsItem(
                        icon: CupertinoIcons.trash,
                        title: 'Clear All Data',
                        onTap: _showClearDataDialog,
                        isDestructive: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? const Color(0xFFFF3B30) : AppColors.white;
    final textColor = isDestructive ? const Color(0xFFFF3B30) : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Icon(CupertinoIcons.forward, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}
