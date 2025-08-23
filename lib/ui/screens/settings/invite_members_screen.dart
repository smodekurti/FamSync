import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';
import 'package:fam_sync/ui/strings.dart';
import 'package:fam_sync/ui/widgets/responsive_error_widget.dart';
import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/family/family_repository.dart';
import 'package:fam_sync/data/invites/invite_repository.dart';
import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/domain/models/family_invite.dart';
import 'package:fam_sync/domain/models/pending_member.dart';
import 'package:fam_sync/domain/models/user_profile.dart';

/// Screen for managing family invitations
/// Allows family owners and parents to create, view, and manage invites
class InviteMembersScreen extends ConsumerStatefulWidget {
  const InviteMembersScreen({super.key});

  @override
  ConsumerState<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends ConsumerState<InviteMembersScreen> {
  bool _isGeneratingInvite = false;
  String? _generatedInviteCode;
  String _selectedRole = 'child';
  int _selectedMaxUses = 1;
  int _selectedExpiryDays = 7;

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final profileAsync = ref.watch(userProfileStreamProvider);

    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: AppStrings.inviteMembersTitle),
      expandedHeight: spaces.xxl * 6,
      fixedActions: [
        const Icon(Icons.share),
        SizedBox(width: spaces.sm),
        const Icon(Icons.qr_code),
        SizedBox(width: spaces.sm),
        const Icon(Icons.settings),
      ],
      headerBuilder: (context, controller) => _buildHeader(profileAsync),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _buildNoProfileContent(context);
          }

          final familyId = profile.familyId;
          print('🔍 [DEBUG] Profile data:');
          print('   - profile.uid: ${profile.uid}');
          print('   - profile.familyId: $familyId');
          print('   - profile.role: ${profile.role}');
          
          if (familyId == null) {
            print('❌ [DEBUG] No family ID found in profile');
            return _buildNoFamilyContent(context);
          }

          print('🔍 [DEBUG] Building invite content with familyId: $familyId');
          return _buildInviteContent(context, familyId);
        },
        loading: () => _buildLoadingContent(context),
        error: (error, stackTrace) => _buildErrorContent(context, error),
      ),
    );
  }

  /// Builds the app bar header with family information
  Widget _buildHeader(AsyncValue<UserProfile?> profileAsync) {
    return profileAsync.when(
      data: (profile) {
        if (profile?.familyId == null) return const SizedBox.shrink();
        
        final familyAsync = ref.watch(familyStreamProvider(profile!.familyId!));
        return familyAsync.when(
          data: (family) => _buildFamilyHeader(family),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Builds the family header information
  Widget _buildFamilyHeader(models.Family? family) {
    print('🔍 [DEBUG] _buildFamilyHeader called with family:');
    if (family == null) {
      print('❌ [DEBUG] Family is null');
      return const SizedBox.shrink();
    }
    
    print('🔍 [DEBUG] Family data:');
    print('   - id: ${family.id}');
    print('   - name: ${family.name}');
    print('   - memberUids: ${family.memberUids}');
    print('   - roles: ${family.roles}');
    print('   - ownerUid: ${family.ownerUid}');
    print('   - allowInvites: ${family.allowInvites}');
    print('   - maxMembers: ${family.maxMembers}');

    final spaces = context.spaces;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          family.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: spaces.xs / 2),
        Row(
          children: [
            Text(
              '${family.memberUids.length}/${family.maxMembers} members',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
            SizedBox(width: spaces.sm),
            Text(
              '• ${family.availableMemberSlots} slots available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the main invite content
  Widget _buildInviteContent(BuildContext context, String familyId) {
    final spaces = context.spaces;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spaces.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Generate Invite Section
          _buildGenerateInviteSection(context, familyId),
          
          SizedBox(height: spaces.lg),
          
          // Active Invites Section
          _buildActiveInvitesSection(context, familyId),
          
          SizedBox(height: spaces.lg),
          
          // Pending Members Section
          _buildPendingMembersSection(context, familyId),
        ],
      ),
    );
  }

  /// Builds the invite generation section
  Widget _buildGenerateInviteSection(BuildContext context, String familyId) {
    final spaces = context.spaces;
    final colors = context.colors;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: colors.primary,
                  size: spaces.xl,
                ),
                SizedBox(width: spaces.sm),
                Text(
                  'Generate New Invite',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            // Role Selection
            _buildRoleSelection(),
            
            SizedBox(height: spaces.md),
            
            // Max Uses Selection
            _buildMaxUsesSelection(),
            
            SizedBox(height: spaces.md),
            
            // Expiry Days Selection
            _buildExpiryDaysSelection(),
            
            SizedBox(height: spaces.lg),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              height: spaces.xxl * 1.5,
              child: ElevatedButton(
                onPressed: _isGeneratingInvite ? null : () => _generateInvite(familyId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(spaces.sm),
                  ),
                ),
                child: _isGeneratingInvite
                    ? SizedBox(
                        width: spaces.lg,
                        height: spaces.lg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                        ),
                      )
                    : Text(
                        'Generate Invite',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            // Generated Invite Code Display
            if (_generatedInviteCode != null) ...[
              SizedBox(height: spaces.lg),
              _buildGeneratedInviteDisplay(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the role selection dropdown
  Widget _buildRoleSelection() {
    final spaces = context.spaces;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spaces.sm),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spaces.sm),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: spaces.md,
              vertical: spaces.sm,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'child',
              child: Text('Child'),
            ),
            DropdownMenuItem(
              value: 'parent',
              child: Text('Parent'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRole = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// Builds the max uses selection
  Widget _buildMaxUsesSelection() {
    final spaces = context.spaces;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maximum Uses',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spaces.sm),
        DropdownButtonFormField<int>(
          value: _selectedMaxUses,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spaces.sm),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: spaces.md,
              vertical: spaces.sm,
            ),
          ),
          items: List.generate(5, (index) => index + 1).map((uses) {
            return DropdownMenuItem(
              value: uses,
              child: Text('$uses time${uses == 1 ? '' : 's'}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedMaxUses = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// Builds the expiry days selection
  Widget _buildExpiryDaysSelection() {
    final spaces = context.spaces;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expires After',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spaces.sm),
        DropdownButtonFormField<int>(
          value: _selectedExpiryDays,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(spaces.sm),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: spaces.md,
              vertical: spaces.sm,
            ),
          ),
          items: [1, 3, 7, 14, 30].map((days) {
            return DropdownMenuItem(
              value: days,
              child: Text('$days day${days == 1 ? '' : 's'}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedExpiryDays = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// Builds the generated invite display
  Widget _buildGeneratedInviteDisplay(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(spaces.lg),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(spaces.lg),
        border: Border.all(color: colors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colors.primary,
                size: spaces.xl,
              ),
              SizedBox(width: spaces.sm),
              Text(
                'Invite Generated Successfully!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: spaces.md),
          
          Text(
            'Share this code with the person you want to invite:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          
          SizedBox(height: spaces.md),
          
          // Invite Code Display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(spaces.lg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(spaces.md),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                Text(
                  _generatedInviteCode!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: spaces.sm),
                Text(
                  'Copy this code and share it',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: spaces.md),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyInviteCode(),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Code'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: spaces.md),
                  ),
                ),
              ),
              SizedBox(width: spaces.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareInviteCode(),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: spaces.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the active invites section
  Widget _buildActiveInvitesSection(BuildContext context, String familyId) {
    final spaces = context.spaces;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: spaces.xl,
                ),
                SizedBox(width: spaces.sm),
                Text(
                  'Active Invites',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            Consumer(
              builder: (context, ref, child) {
                final invitesAsync = ref.watch(familyInvitesProvider(familyId));
                return invitesAsync.when(
                  data: (invites) {
                    if (invites.isEmpty) {
                      return _buildEmptyInvitesState(context);
                    }
                    return _buildInvitesList(context, invites);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => _buildInvitesErrorState(context, error),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the pending members section
  Widget _buildPendingMembersSection(BuildContext context, String familyId) {
    final spaces = context.spaces;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions,
                  color: Theme.of(context).colorScheme.primary,
                  size: spaces.xl,
                ),
                SizedBox(width: spaces.sm),
                Text(
                  'Pending Members',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            Consumer(
              builder: (context, ref, child) {
                final pendingAsync = ref.watch(pendingMembersProvider(familyId));
                return pendingAsync.when(
                  data: (pendingMembers) {
                    if (pendingMembers.isEmpty) {
                      return _buildEmptyPendingState(context);
                    }
                    return _buildPendingMembersList(context, pendingMembers);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => _buildPendingErrorState(context, error),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty invites state
  Widget _buildEmptyInvitesState(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Container(
      padding: EdgeInsets.all(spaces.xl),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: spaces.xxl * 2,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: spaces.md),
          Text(
            'No Active Invites',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spaces.sm),
          Text(
            'Generate an invite above to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the invites list
  Widget _buildInvitesList(BuildContext context, List<FamilyInvite> invites) {
    return Column(
      children: invites.map((invite) => _buildInviteTile(context, invite)).toList(),
    );
  }

  /// Builds an individual invite tile
  Widget _buildInviteTile(BuildContext context, FamilyInvite invite) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Card(
      margin: EdgeInsets.only(bottom: spaces.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            invite.role[0].toUpperCase(),
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${invite.role.capitalize()} Invite',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${invite.inviteCode}'),
            Text('Expires: ${invite.daysUntilExpiry} days'),
            Text('Uses: ${invite.useCount}/${invite.maxUses}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleInviteAction(value, invite),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy',
              child: Text('Copy Code'),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Text('Share'),
            ),
            const PopupMenuItem(
              value: 'revoke',
              child: Text('Revoke'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty pending state
  Widget _buildEmptyPendingState(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Container(
      padding: EdgeInsets.all(spaces.xl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: spaces.xxl * 2,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: spaces.md),
          Text(
            'No Pending Members',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spaces.sm),
          Text(
            'When someone accepts an invite, they\'ll appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the pending members list
  Widget _buildPendingMembersList(BuildContext context, List<PendingMember> pendingMembers) {
    return Column(
      children: pendingMembers.map((member) => _buildPendingMemberTile(context, member)).toList(),
    );
  }

  /// Builds an individual pending member tile
  Widget _buildPendingMemberTile(BuildContext context, PendingMember member) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Card(
      margin: EdgeInsets.only(bottom: spaces.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          child: Text(
            member.displayName[0].toUpperCase(),
            style: TextStyle(
              color: colors.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email),
            Text('Role: ${member.role.capitalize()}'),
            Text('Invited: ${member.daysSinceInvited} days ago'),
            Text('Status: ${member.statusDescription}'),
          ],
        ),
        trailing: member.shouldSendReminder
            ? ElevatedButton(
                onPressed: () => _sendReminder(member.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: spaces.md,
                    vertical: spaces.sm,
                  ),
                ),
                child: Text(member.actionText),
              )
            : Text(
                member.actionText,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }

  /// Builds error states for various sections
  Widget _buildInvitesErrorState(BuildContext context, Object error) {
    return ResponsiveErrorWidget(
      error: error,
      onRetry: () => ref.invalidate(familyInvitesProvider),
    );
  }

  Widget _buildPendingErrorState(BuildContext context, Object error) {
    return ResponsiveErrorWidget(
      error: error,
      onRetry: () => ref.invalidate(pendingMembersProvider),
    );
  }

  /// Builds loading and error states
  Widget _buildLoadingContent(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorContent(BuildContext context, Object error) {
    return ResponsiveErrorWidget(
      error: error,
      onRetry: () => ref.invalidate(userProfileStreamProvider),
    );
  }

  Widget _buildNoProfileContent(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: spaces.xxl * 2,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: spaces.md),
          Text(
            'No Profile Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spaces.sm),
          Text(
            'Please complete your profile setup first',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFamilyContent(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom_outlined,
            size: spaces.xxl * 2,
            color: colors.onSurfaceVariant,
          ),
          SizedBox(height: spaces.md),
          Text(
            'No Family Context',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spaces.sm),
          Text(
            'You need to be part of a family to invite members',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Handles invite generation
  Future<void> _generateInvite(String familyId) async {
    print('🔍 [DEBUG] _generateInvite called with familyId: $familyId');
    
    setState(() {
      _isGeneratingInvite = true;
    });

    try {
      print('🔍 [DEBUG] Step 1: Getting current user...');
      final currentUser = ref.read(authStateProvider).value;
      print('🔍 [DEBUG] Current user: ${currentUser?.uid}');
      
      if (currentUser == null) {
        print('❌ [DEBUG] User not authenticated');
        throw Exception('User not authenticated');
      }

      print('🔍 [DEBUG] Step 2: Getting invite repository...');
      final inviteRepository = ref.read(inviteRepositoryProvider);
      print('🔍 [DEBUG] Invite repository obtained');

      print('🔍 [DEBUG] Step 3: Calling createInvite with parameters:');
      print('   - familyId: $familyId');
      print('   - createdByUid: ${currentUser.uid}');
      print('   - role: $_selectedRole');
      print('   - maxUses: $_selectedMaxUses');
      print('   - daysUntilExpiry: $_selectedExpiryDays');

      final invite = await inviteRepository.createInvite(
        familyId: familyId,
        createdByUid: currentUser.uid,
        role: _selectedRole,
        maxUses: _selectedMaxUses,
        daysUntilExpiry: _selectedExpiryDays,
      );

      print('✅ [DEBUG] Invite created successfully!');
      print('   - invite id: ${invite.id}');
      print('   - invite code: ${invite.inviteCode}');

      setState(() {
        _generatedInviteCode = invite.inviteCode;
        _isGeneratingInvite = false;
      });

      print('🔍 [DEBUG] Step 4: Invalidating invites provider...');
      // Invalidate the invites provider to refresh the list
      ref.invalidate(familyInvitesProvider);
      print('✅ [DEBUG] Invite generation completed successfully!');
      
    } catch (e) {
      print('❌ [DEBUG] ERROR in _generateInvite:');
      print('   - Error type: ${e.runtimeType}');
      print('   - Error message: $e');
      print('   - Error toString: ${e.toString()}');
      print('   - Stack trace: ${StackTrace.current}');
      
      setState(() {
        _isGeneratingInvite = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating invite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Copies the invite code to clipboard
  void _copyInviteCode() {
    if (_generatedInviteCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedInviteCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite code copied to clipboard')),
      );
    }
  }

  /// Shares the invite code
  void _shareInviteCode() {
    if (_generatedInviteCode != null) {
      // TODO: Implement native sharing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing coming soon!')),
      );
    }
  }

  /// Handles invite actions
  void _handleInviteAction(String action, FamilyInvite invite) {
    switch (action) {
      case 'copy':
        Clipboard.setData(ClipboardData(text: invite.inviteCode));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite code copied to clipboard')),
        );
        break;
      case 'share':
        // TODO: Implement native sharing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sharing coming soon!')),
        );
        break;
      case 'revoke':
        _revokeInvite(invite);
        break;
    }
  }

  /// Revokes an invite
  Future<void> _revokeInvite(FamilyInvite invite) async {
    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final inviteRepository = ref.read(inviteRepositoryProvider);
      await inviteRepository.revokeInvite(
        inviteId: invite.id,
        revokedByUid: currentUser.uid,
      );

      // Invalidate the invites provider to refresh the list
      ref.invalidate(familyInvitesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite revoked successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error revoking invite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Sends a reminder to a pending member
  Future<void> _sendReminder(String pendingMemberId) async {
    try {
      final inviteRepository = ref.read(inviteRepositoryProvider);
      await inviteRepository.sendReminder(pendingMemberId);
      
      // Invalidate the pending members provider to refresh the list
      ref.invalidate(pendingMembersProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reminder: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
