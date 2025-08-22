import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/widgets/responsive_error_widget.dart';

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
  final String _language = 'English';
  bool _isSigningOut = false;
  Object? _signOutError;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final layout = context.layout;
    final profileAsync = ref.watch(userProfileStreamProvider);

    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.settingsTitle),
      expandedHeight: layout.isSmall ? spaces.xxl * 4 : spaces.xxl * 6,
      fixedActions: [
        const Icon(Icons.settings),
        SizedBox(width: spaces.sm),
        const Icon(Icons.help_outline),
        SizedBox(width: spaces.sm),
        const Icon(Icons.person_outline),
      ],
      extraActions: const [],
      padding: EdgeInsets.all(spaces.md),
      headerBuilder: (context, controller) => _settingsHeader(profileAsync: profileAsync),
      body: _isSigningOut 
          ? _buildSigningOutContent(context)
          : _signOutError != null
              ? _buildSignOutErrorContent(context)
              : profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off,
                              size: spaces.xxl * 2,
                              color: context.colors.onSurfaceVariant,
                            ),
                            SizedBox(height: spaces.md),
                            Text(
                              AppStrings.noProfileFound,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final familyId = profile.familyId;
                    if (familyId == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.family_restroom_outlined,
                              size: spaces.xxl * 2,
                              color: context.colors.onSurfaceVariant,
                            ),
                            SizedBox(height: spaces.md),
                            Text(
                              AppStrings.noFamilyContext,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final familyAsync = ref.watch(familyStreamProvider(familyId));

                    return familyAsync.when(
                      data: (family) => _buildSettingsContent(context, profile, family),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: spaces.xxl * 2,
                              color: context.colors.error,
                            ),
                            SizedBox(height: spaces.md),
                            Text(
                              AppStrings.errorLoadingFamily,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.colors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: spaces.xxl * 2,
                          color: context.colors.error,
                        ),
                        SizedBox(height: spaces.md),
                        Text(
                          AppStrings.errorLoadingProfile,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    UserProfile profile,
    models.Family? family,
  ) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header
          ProfileHeader(profile: profile, family: family),
          SizedBox(height: spaces.lg),

          // Profile & Family Management
          SettingsSection(
            title: AppStrings.profileFamilyTitle,
            icon: Icons.family_restroom,
            children: [
              SettingsTile(
                icon: Icons.person,
                title: AppStrings.editProfileTitle,
                subtitle: AppStrings.editProfileSubtitle,
                onTap: () => _editProfile(context, profile),
              ),
              SettingsTile(
                icon: Icons.family_restroom,
                title: AppStrings.familySettingsTitle,
                subtitle: family?.name ?? 'Family',
                onTap: () => _editFamilySettings(context, family),
              ),
              SettingsTile(
                icon: Icons.person_add,
                title: AppStrings.inviteMembersTitle,
                subtitle: AppStrings.inviteMembersSubtitle,
                onTap: () => _inviteMembers(context, family),
              ),
              if (profile.role == UserRole.parent) ...[
                SettingsTile(
                  icon: Icons.manage_accounts,
                  title: AppStrings.manageMembersTitle,
                  subtitle: AppStrings.manageMembersSubtitle,
                  onTap: () => _manageMembers(context, family),
                ),
              ],
            ],
          ),
          SizedBox(height: spaces.md),

          // App Preferences
          SettingsSection(
            title: AppStrings.appPreferencesTitle,
            icon: Icons.settings,
            children: [
              SettingsTile(
                icon: Icons.palette,
                title: AppStrings.themeTitle,
                subtitle: _darkModeEnabled ? AppStrings.darkMode : AppStrings.lightMode,
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
                title: AppStrings.languageTitle,
                subtitle: _language,
                onTap: () => _selectLanguage(context),
              ),
              SettingsTile(
                icon: Icons.text_fields,
                title: AppStrings.fontSizeTitle,
                subtitle: AppStrings.fontSizeSubtitle,
                onTap: () => _adjustFontSize(context),
              ),
            ],
          ),
          SizedBox(height: spaces.md),

          // Notifications
          SettingsSection(
            title: AppStrings.notificationsTitle,
            icon: Icons.notifications,
            children: [
              SettingsTile(
                icon: Icons.notifications_active,
                title: AppStrings.pushNotificationsTitle,
                subtitle: AppStrings.pushNotificationsSubtitle,
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
                  title: AppStrings.soundTitle,
                  subtitle: AppStrings.soundSubtitle,
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
                  title: AppStrings.vibrationTitle,
                  subtitle: AppStrings.vibrationSubtitle,
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
                  title: AppStrings.eventRemindersTitle,
                  subtitle: AppStrings.eventRemindersSubtitle,
                  onTap: () => _configureEventReminders(context),
                ),
                SettingsTile(
                  icon: Icons.task,
                  title: AppStrings.taskNotificationsTitle,
                  subtitle: AppStrings.taskNotificationsSubtitle,
                  onTap: () => _configureTaskNotifications(context),
                ),
              ],
            ],
          ),
          SizedBox(height: spaces.md),

          // Support & About
          SettingsSection(
            title: AppStrings.supportAboutTitle,
            icon: Icons.help,
            children: [
              SettingsTile(
                icon: Icons.help_outline,
                title: AppStrings.helpFaqTitle,
                subtitle: AppStrings.helpFaqSubtitle,
                onTap: () => _showHelp(context),
              ),
              SettingsTile(
                icon: Icons.bug_report,
                title: AppStrings.reportBugTitle,
                subtitle: AppStrings.reportBugSubtitle,
                onTap: () => _reportBug(context),
              ),
              SettingsTile(
                icon: Icons.feedback,
                title: AppStrings.sendFeedbackTitle,
                subtitle: AppStrings.sendFeedbackSubtitle,
                onTap: () => _sendFeedback(context),
              ),
              SettingsTile(
                icon: Icons.info,
                title: AppStrings.aboutTitle,
                subtitle: AppStrings.aboutSubtitle,
                onTap: () => _showAbout(context),
              ),
            ],
          ),
          SizedBox(height: layout.isSmall ? spaces.md : spaces.lg),

          // Sign Out Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: spaces.md),
            child: OutlinedButton.icon(
              onPressed: _isSigningOut ? null : () => _signOut(context),
              icon: _isSigningOut 
                  ? SizedBox(
                      width: spaces.md,
                      height: spaces.md,
                      child: CircularProgressIndicator(
                        strokeWidth: spaces.xs / 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(_isSigningOut ? AppStrings.signingOut : AppStrings.signOut),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
                padding: EdgeInsets.symmetric(vertical: spaces.md),
              ),
            ),
          ),
          SizedBox(height: layout.isSmall ? spaces.lg : spaces.xl),
        ],
      ),
    );
  }

  // Action Methods
  void _editProfile(BuildContext context, UserProfile profile) {
    // TODO: Navigate to profile editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.editProfileTitle} coming soon!')),
    );
  }

  void _editFamilySettings(BuildContext context, models.Family? family) {
    // TODO: Navigate to family settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.familySettingsTitle} coming soon!')),
    );
  }

  void _inviteMembers(BuildContext context, models.Family? family) {
    // TODO: Show invite members dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.inviteMembersTitle} coming soon!')),
    );
  }

  void _manageMembers(BuildContext context, models.Family? family) {
    // TODO: Navigate to member management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.manageMembersTitle} coming soon!')),
    );
  }

  void _selectLanguage(BuildContext context) {
    // TODO: Show language selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.languageTitle} selection coming soon!')),
    );
  }

  void _adjustFontSize(BuildContext context) {
    // TODO: Show font size adjustment dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.fontSizeTitle} adjustment coming soon!')),
    );
  }

  void _configureEventReminders(BuildContext context) {
    // TODO: Show event reminder configuration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.eventRemindersTitle} configuration coming soon!')),
    );
  }

  void _configureTaskNotifications(BuildContext context) {
    // TODO: Show task notification configuration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.taskNotificationsTitle} configuration coming soon!')),
    );
  }

  void _showHelp(BuildContext context) {
    // TODO: Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.helpFaqTitle} coming soon!')),
    );
  }

  void _reportBug(BuildContext context) {
    // TODO: Show bug report dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.reportBugTitle} coming soon!')),
    );
  }

  void _sendFeedback(BuildContext context) {
    // TODO: Show feedback dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${AppStrings.sendFeedbackTitle} coming soon!')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.family_restroom),
      children: [
        Text(AppStrings.appDescription),
        SizedBox(height: context.spaces.md),
        Text(AppStrings.appBuiltWith),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    if (_isSigningOut) return; // Prevent multiple sign-out attempts
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.signOutTitle),
        content: Text(AppStrings.signOutSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSigningOut = true;
        _signOutError = null; // Clear any previous errors
      });
      
      try {
        // Show loading state
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.signingOut),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        print('Starting sign out process...'); // Debug log
        
        // Perform sign-out
        await ref.read(authRepositoryProvider).signOut();
        
        print('Sign out completed successfully'); // Debug log
        
        // Success - AuthGate will handle navigation automatically
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.signOutSuccess),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        print('Sign out error: $e'); // Debug log
        
        if (mounted) {
          setState(() {
            _isSigningOut = false;
            _signOutError = e; // Store the error for display
          });
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.errorSignOutRetry),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _settingsHeader({required AsyncValue<UserProfile?> profileAsync}) {
    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        
        final familyId = profile.familyId;
        if (familyId == null) return const SizedBox.shrink();
        
        final familyAsync = ref.watch(familyStreamProvider(familyId));
        return familyAsync.when(
          data: (family) => _buildHeaderContent(profile, family),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildHeaderContent(UserProfile profile, models.Family? family) {
    final spaces = context.spaces;
    final layout = context.layout;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.settingsHeaderTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spaces.xs / 4),
              Text(
                AppStrings.settingsHeaderSubtitle,
                maxLines: layout.isSmall ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: spaces.md),
        // Profile Avatar Preview
        Container(
          width: spaces.lg,
          height: spaces.lg,
          decoration: BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              profile.displayName.isNotEmpty 
                  ? profile.displayName[0].toUpperCase() 
                  : '?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSigningOutContent(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    final layout = context.layout;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: layout.isSmall ? spaces.xxl * 3 : spaces.xxl * 4,
            height: layout.isSmall ? spaces.xxl * 3 : spaces.xxl * 4,
            child: CircularProgressIndicator(
              strokeWidth: spaces.sm,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          SizedBox(height: spaces.lg),
          Text(
            AppStrings.signingOut,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: spaces.sm),
          Text(
            AppStrings.signingOutMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutErrorContent(BuildContext context) {
    final spaces = context.spaces;
    final layout = context.layout;
    
    return ResponsiveErrorWidget(
      error: _signOutError!,
      onRetry: () => _retrySignOut(context),
      actions: [
        // Force Sign Out Button
        SizedBox(
          width: layout.isSmall ? double.infinity : spaces.xxl * 12,
          height: spaces.xxl * 1.5,
          child: OutlinedButton(
            onPressed: () => _showForceSignOutDialog(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(spaces.sm),
              ),
            ),
            child: Text(
              AppStrings.errorSignOutForce,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showForceSignOutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.errorSignOutForce),
        content: Text(AppStrings.errorSignOutForceMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.errorSignOutForceCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.onError,
            ),
            child: Text(AppStrings.errorSignOutForceConfirm),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        _forceSignOut(context);
      }
    });
  }

  void _forceSignOut(BuildContext context) {
    // Force close the app to bypass any remaining issues
    // This is a last resort when normal sign out fails
    SystemNavigator.pop();
  }

  void _retrySignOut(BuildContext context) {
    setState(() {
      _signOutError = null;
    });
    _signOut(context);
  }
}
