import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/icons.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/family/family_repository.dart';
import 'package:fam_sync/domain/models/user_profile.dart';
import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/ui/screens/settings/widgets/settings_section.dart';
import 'package:fam_sync/ui/screens/settings/widgets/settings_tile.dart';
import 'package:fam_sync/ui/screens/settings/widgets/profile_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final profileAsync = ref.watch(userProfileStreamProvider);

    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: 'Settings'),
      fixedActions: [
        const Icon(Icons.settings),
        SizedBox(width: spaces.sm),
        const Icon(Icons.help_outline),
        SizedBox(width: spaces.sm),
        const Icon(Icons.person_outline),
      ],
      extraActions: const [],
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          final familyId = profile.familyId;
          if (familyId == null) {
            return const Center(child: Text('No family context'));
          }

          final familyAsync = ref.watch(familyStreamProvider(familyId));

          return familyAsync.when(
            data: (family) => _buildSettingsContent(context, profile, family, spaces, colors),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading family')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    UserProfile profile,
    models.Family? family,
    dynamic spaces,
    ColorScheme colors,
  ) {
    return ListView(
      padding: EdgeInsets.all(spaces.md),
      children: [
        // Profile Header
        ProfileHeader(profile: profile, family: family),
        SizedBox(height: spaces.lg),

        // Profile & Family Management
        SettingsSection(
          title: 'Profile & Family',
          icon: Icons.family_restroom,
          children: [
            SettingsTile(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Change your name, email, and photo',
              onTap: () => _editProfile(context, profile),
            ),
            SettingsTile(
              icon: Icons.family_restroom,
              title: 'Family Settings',
              subtitle: family?.name ?? 'Family',
              onTap: () => _editFamilySettings(context, family),
            ),
            SettingsTile(
              icon: Icons.person_add,
              title: 'Invite Members',
              subtitle: 'Send invite codes to new family members',
              onTap: () => _inviteMembers(context, family),
            ),
            if (profile.role == UserRole.parent) ...[
              SettingsTile(
                icon: Icons.manage_accounts,
                title: 'Manage Members',
                subtitle: 'Remove members or change roles',
                onTap: () => _manageMembers(context, family),
              ),
            ],
          ],
        ),
        SizedBox(height: spaces.md),

        // App Preferences
        SettingsSection(
          title: 'App Preferences',
          icon: Icons.settings,
          children: [
            SettingsTile(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: _darkModeEnabled ? 'Dark Mode' : 'Light Mode',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                  // TODO: Implement theme switching
                },
              ),
            ),
            SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              onTap: () => _selectLanguage(context),
            ),
            SettingsTile(
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Adjust text size for better readability',
              onTap: () => _adjustFontSize(context),
            ),
          ],
        ),
        SizedBox(height: spaces.md),

        // Notifications
        SettingsSection(
          title: 'Notifications',
          icon: Icons.notifications,
          children: [
            SettingsTile(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive notifications on your device',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // TODO: Implement notification toggle
                },
              ),
            ),
            if (_notificationsEnabled) ...[
              SettingsTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                    // TODO: Implement sound toggle
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate for notifications',
                trailing: Switch(
                  value: _vibrationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _vibrationEnabled = value;
                    });
                    // TODO: Implement vibration toggle
                  },
                ),
              ),
              SettingsTile(
                icon: Icons.event,
                title: 'Event Reminders',
                subtitle: 'Get notified before events',
                onTap: () => _configureEventReminders(context),
              ),
              SettingsTile(
                icon: Icons.task,
                title: 'Task Notifications',
                subtitle: 'Get notified about task deadlines',
                onTap: () => _configureTaskNotifications(context),
              ),
            ],
          ],
        ),
        SizedBox(height: spaces.md),

        // Support & About
        SettingsSection(
          title: 'Support & About',
          icon: Icons.help,
          children: [
            SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get help with using FamSync',
              onTap: () => _showHelp(context),
            ),
            SettingsTile(
              icon: Icons.bug_report,
              title: 'Report Bug',
              subtitle: 'Help us improve by reporting issues',
              onTap: () => _reportBug(context),
            ),
            SettingsTile(
              icon: Icons.feedback,
              title: 'Send Feedback',
              subtitle: 'Share your thoughts and suggestions',
              onTap: () => _sendFeedback(context),
            ),
            SettingsTile(
              icon: Icons.info,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () => _showAbout(context),
            ),
          ],
        ),
        SizedBox(height: spaces.lg),

        // Sign Out Button
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: spaces.md),
          child: OutlinedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error),
              padding: EdgeInsets.symmetric(vertical: spaces.md),
            ),
          ),
        ),
        SizedBox(height: spaces.xl),
      ],
    );
  }

  // Action Methods
  void _editProfile(BuildContext context, UserProfile profile) {
    // TODO: Navigate to profile editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile editing coming soon!')),
    );
  }

  void _editFamilySettings(BuildContext context, Family? family) {
    // TODO: Navigate to family settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family settings coming soon!')),
    );
  }

  void _inviteMembers(BuildContext context, Family? family) {
    // TODO: Show invite members dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite members coming soon!')),
    );
  }

  void _manageMembers(BuildContext context, Family? family) {
    // TODO: Navigate to member management screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member management coming soon!')),
    );
  }

  void _selectLanguage(BuildContext context) {
    // TODO: Show language selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language selection coming soon!')),
    );
  }

  void _adjustFontSize(BuildContext context) {
    // TODO: Show font size adjustment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Font size adjustment coming soon!')),
    );
  }

  void _configureEventReminders(BuildContext context) {
    // TODO: Show event reminder configuration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event reminders configuration coming soon!')),
    );
  }

  void _configureTaskNotifications(BuildContext context) {
    // TODO: Show task notification configuration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task notifications configuration coming soon!')),
    );
  }

  void _showHelp(BuildContext context) {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & FAQ coming soon!')),
    );
  }

  void _reportBug(BuildContext context) {
    // TODO: Show bug report dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug reporting coming soon!')),
    );
  }

  void _sendFeedback(BuildContext context) {
    // TODO: Show feedback dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback submission coming soon!')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FamSync',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.family_restroom),
      children: [
        const Text('A family organization and communication app.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and Firebase.'),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authRepositoryProvider).signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }
}
