import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/database_helper.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../screens/profile_screen.dart';
import '../screens/auth_screen.dart';             // ✅ CHANGED: now imports auth_screen
import '../../data/providers/auth_provider.dart' as app_auth;
import '../../core/services/backend_api_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _openMail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: 'support@example.com', query: 'subject=Workout Logger Feedback');
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No email app found on this device')));
    }
  }

  void _showServerSettingsDialog(BuildContext context) {
  final controller = TextEditingController(
    text: BackendApiService.baseUrl.replaceFirst('http://', '').replaceFirst('/api/v1', ''),
  );
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.card(dialogContext),
      title: const Text('Backend Server Address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'If your PC\'s IP address changes, update it here — no rebuild needed.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(dialogContext)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '192.168.1.6:5000'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            await BackendApiService.updateBaseUrl(controller.text);
            if (context.mounted) Navigator.of(dialogContext).pop();
          },
          child: const Text('Save', style: TextStyle(color: AppTheme.lime)),
        ),
      ],
    ),
  );
}

  Future<void> _inviteFriend() async {
    await Share.share('I\'ve been using Workout Logger to track my workouts and nutrition offline — thought you might like it too!');
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Rate the app'),
        content: Text(
          'This build isn\'t distributed through the Play Store yet, so in-store ratings aren\'t available. Thanks for trying it out!',
          style: TextStyle(color: AppTheme.textSecondary(dialogContext)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Got it', style: TextStyle(color: AppTheme.lime))),
        ],
      ),
    );
  }

  Widget _helpItem(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary(context))),
          const SizedBox(height: 3),
          Text(body, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
              const SizedBox(height: 16),
              _helpItem(sheetContext, 'Logging a workout', 'Go to Workout → Start Workout Session, add exercises, tap the circle to complete each set.'),
              _helpItem(sheetContext, 'Logging food', 'Go to Nutrition, search the food database or add a Custom Dish.'),
              _helpItem(sheetContext, 'Your data', 'Everything is stored locally on this device. Nothing is uploaded anywhere.'),
              Text('Still stuck? Use Feedback below to reach out.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(sheetContext))),
            ],
          ),
        );
      },
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Workout Logger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(sheetContext))),
              const SizedBox(height: 10),
              Text(
                'An offline-first fitness, nutrition and progress tracker. Version 1.0.0.\nAll data stays on this device.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(sheetContext)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.card(dialogContext),
        title: const Text('Sign out?'),
        content: Text(
          'This deletes your local profile and everything you\'ve logged — workouts, nutrition, weight history. This can\'t be undone.',
          style: TextStyle(color: AppTheme.textSecondary(dialogContext)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Sign out', style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (confirmed != true) return;

    await DatabaseHelper.resetAllUserData(1);
    await context.read<app_auth.AuthProvider>().signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),   // ✅ CHANGED: now goes to AuthScreen
      (route) => false,
    );
  }

  Widget _drawerTile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final resolvedColor = color ?? AppTheme.textPrimary(context);
    return ListTile(
      leading: Icon(icon, color: resolvedColor),
      title: Text(label, style: TextStyle(fontSize: 14, color: resolvedColor)),
      onTap: onTap,
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.card(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final user = userProvider.currentUser;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.lime.withValues(alpha: 0.15),
                        child: Text(
                          user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppTheme.lime, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.name ?? 'Guest', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary(context))),
                            const SizedBox(height: 2),
                            Text('Offline profile', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context))),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(color: AppTheme.divider(context), height: 1),
            const SizedBox(height: 8),
            _drawerTile(context, Icons.person_outline, 'My Profile', () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return ListTile(
                  leading: Icon(Icons.brightness_6_outlined, color: AppTheme.textPrimary(context)),
                  title: Text('Dark Mode', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary(context))),
                  trailing: Switch(
                    value: themeProvider.isDark,
                    activeThumbColor: AppTheme.lime,
                    onChanged: (value) => themeProvider.setDarkMode(value),
                  ),
                );
              },
            ),
            _drawerTile(context, Icons.help_outline, 'Help', () {
              Navigator.of(context).pop();
              _showHelpSheet(context);
            }),
            _drawerTile(context, Icons.feedback_outlined, 'Feedback', () {
              Navigator.of(context).pop();
              _openMail(context);
            }),
            _drawerTile(context, Icons.people_outline, 'Invite a Friend', () {
              Navigator.of(context).pop();
              _inviteFriend();
            }),
            _drawerTile(context, Icons.star_outline, 'Rate the app', () {
              Navigator.of(context).pop();
              _showRateDialog(context);
            }),
            _drawerTile(context, Icons.info_outline, 'About Us', () {
              Navigator.of(context).pop();
              _showAboutSheet(context);
            }),
            _drawerTile(context, Icons.dns_outlined, 'Server Connection', () {
              Navigator.of(context).pop();
              _showServerSettingsDialog(context);
            }),
            const Spacer(),
            Divider(color: AppTheme.divider(context), height: 1),
            _drawerTile(context, Icons.logout, 'Sign Out', () => _confirmSignOut(context), color: AppTheme.danger),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}