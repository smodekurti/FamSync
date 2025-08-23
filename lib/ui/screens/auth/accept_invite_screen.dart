import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fam_sync/theme/app_theme.dart';
import 'package:fam_sync/ui/appbar/fam_app_bar_scaffold.dart';
import 'package:fam_sync/ui/widgets/family_app_bar_title.dart';

import 'package:fam_sync/data/auth/auth_repository.dart';
import 'package:fam_sync/data/invites/invite_repository.dart';
import 'package:fam_sync/domain/models/family.dart' as models;
import 'package:fam_sync/domain/models/invite_validation_result.dart';

/// Screen for accepting family invitations
/// Users can enter invite codes to join families
class AcceptInviteScreen extends ConsumerStatefulWidget {
  const AcceptInviteScreen({super.key});

  @override
  ConsumerState<AcceptInviteScreen> createState() => _AcceptInviteScreenState();
}

class _AcceptInviteScreenState extends ConsumerState<AcceptInviteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isValidating = false;
  bool _isAccepting = false;
  InviteValidationResult? _validationResult;
  String? _prefilledCode;

  @override
  void initState() {
    super.initState();
    // Extract invite code from URL if present
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractInviteCodeFromUrl();
    });
  }

  /// Extracts invite code from URL query parameters
  void _extractInviteCodeFromUrl() {
    print('🔍 [DEBUG] ===== URL EXTRACTION START =====');
    print('🔍 [DEBUG] Current context: ${context.toString()}');
    
    try {
      final uri = Uri.parse(GoRouterState.of(context).uri.toString());
      print('🔍 [DEBUG] Parsed URI: $uri');
      print('🔍 [DEBUG] URI query parameters: ${uri.queryParameters}');
      
      final code = uri.queryParameters['code'];
      print('🔍 [DEBUG] Extracted code parameter: "$code"');
      
      if (code != null && code.isNotEmpty) {
        print('🔍 [DEBUG] Code is valid, updating UI state');
        setState(() {
          _prefilledCode = code;
          _inviteCodeController.text = code;
        });
        print('🔍 [DEBUG] UI state updated with prefilled code');
        
        // Auto-validate the prefilled code
        print('🔍 [DEBUG] Auto-validating prefilled code...');
        _validateInviteCode();
      } else {
        print('🔍 [DEBUG] No valid code found in URL parameters');
      }
    } catch (e, stackTrace) {
      print('❌ [DEBUG] ===== URL EXTRACTION ERROR =====');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error message: $e');
      print('❌ [DEBUG] Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;

    return FamAppBarScaffold(
      title: const FamilyAppBarTitle(fallback: 'Join Family'),
      expandedHeight: spaces.xxl * 6,
      headerBuilder: (context, controller) => _buildHeader(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spaces.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),
            
            SizedBox(height: spaces.lg),
            
            // Invite Code Form
            _buildInviteCodeForm(context),
            
            SizedBox(height: spaces.lg),
            
            // Validation Result Display
            if (_validationResult != null) ...[
              _buildValidationResult(context),
              SizedBox(height: spaces.lg),
            ],
            
            // Family Preview (if valid)
            if (_validationResult?.isValid == true && _validationResult?.family != null) ...[
              _buildFamilyPreview(context, _validationResult!.family!),
              SizedBox(height: spaces.lg),
            ],
            
            // Accept Button (if valid)
            if (_validationResult?.isValid == true) ...[
              _buildAcceptButton(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the app bar header
  Widget _buildHeader() {
    final spaces = context.spaces;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join a Family',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: spaces.xs / 2),
        Text(
          'Enter the invite code to join a family',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Builds the welcome section
  Widget _buildWelcomeSection(BuildContext context) {
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
          children: [
            Icon(
              Icons.family_restroom,
              size: spaces.xxl * 2,
              color: colors.primary,
            ),
            SizedBox(height: spaces.md),
            Text(
              'Welcome to FamSync!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spaces.sm),
            Text(
              _prefilledCode != null 
                  ? 'We found an invite code! Review the details below and join the family.'
                  : 'You\'ve been invited to join a family. Enter the invite code below to get started.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the invite code form
  Widget _buildInviteCodeForm(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spaces.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(spaces.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _prefilledCode != null ? 'Invite Code (Prefilled)' : 'Invite Code',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spaces.sm),
              Text(
                _prefilledCode != null 
                    ? 'The invite code has been automatically filled. You can modify it if needed.'
                    : 'Enter the 8-character invite code you received',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              SizedBox(height: spaces.md),
              TextFormField(
                controller: _inviteCodeController,
                decoration: InputDecoration(
                  hintText: 'e.g., ABC12345',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(spaces.sm),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _isValidating
                      ? SizedBox(
                          width: spaces.lg,
                          height: spaces.lg,
                          child: Padding(
                            padding: EdgeInsets.all(spaces.xs),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                            ),
                          ),
                        )
                      : null,
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an invite code';
                  }
                  if (value.length != 8) {
                    return 'Invite code must be 8 characters';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Clear validation result when user types
                  if (_validationResult != null) {
                    setState(() {
                      _validationResult = null;
                    });
                  }
                },
              ),
              SizedBox(height: spaces.md),
              SizedBox(
                width: double.infinity,
                height: spaces.xxl * 1.5,
                child: ElevatedButton(
                  onPressed: _isValidating ? null : _validateInviteCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spaces.sm),
                    ),
                  ),
                  child: Text(
                    'Validate Code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the validation result display
  Widget _buildValidationResult(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    if (_validationResult == null) return const SizedBox.shrink();

    final isValid = _validationResult!.isValid;
    final icon = isValid ? Icons.check_circle : Icons.error;
    final iconColor = isValid ? colors.primary : colors.error;
    final backgroundColor = isValid ? colors.primaryContainer : colors.errorContainer;
    final borderColor = isValid ? colors.primary : colors.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spaces.lg),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(spaces.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: spaces.xl,
              ),
              SizedBox(width: spaces.sm),
              Expanded(
                child: Text(
                  isValid ? 'Valid Invite Code!' : 'Invalid Invite Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spaces.sm),
          Text(
            _validationResult!.userFriendlyErrorMessage.isEmpty
                ? 'You can now join this family!'
                : _validationResult!.userFriendlyErrorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the family preview section
  Widget _buildFamilyPreview(BuildContext context, models.Family family) {
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
                  Icons.family_restroom,
                  color: colors.primary,
                  size: spaces.xl,
                ),
                SizedBox(width: spaces.sm),
                Text(
                  'Family Preview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: spaces.md),
            
            // Family Name
            _buildPreviewRow('Family Name', family.name),
            
            SizedBox(height: spaces.sm),
            
            // Member Count
            _buildPreviewRow('Members', '${family.memberUids.length}/${family.maxMembers}'),
            
            SizedBox(height: spaces.sm),
            
            // Available Slots
            _buildPreviewRow('Available Slots', '${family.availableMemberSlots}'),
            
            SizedBox(height: spaces.sm),
            
            // Created Date
            _buildPreviewRow('Created', family.createdAt != null ? _formatDate(family.createdAt!) : 'Unknown'),
          ],
        ),
      ),
    );
  }

  /// Builds a preview row
  Widget _buildPreviewRow(String label, String value) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: spaces.xxl * 3,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the accept button
  Widget _buildAcceptButton(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return SizedBox(
      width: double.infinity,
      height: spaces.xxl * 1.5,
      child: ElevatedButton(
        onPressed: _isAccepting ? null : _acceptInvite,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spaces.sm),
          ),
        ),
        child: _isAccepting
            ? SizedBox(
                width: spaces.lg,
                height: spaces.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                ),
              )
            : Text(
                'Join Family',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Validates the invite code entered by the user
  Future<void> _validateInviteCode() async {
    print('🔍 [DEBUG] ===== UI VALIDATION START =====');
    print('🔍 [DEBUG] Invite code from controller: "${_inviteCodeController.text}"');
    print('🔍 [DEBUG] Current validation state: _isValidating = $_isValidating');
    
    if (_inviteCodeController.text.trim().isEmpty) {
      print('❌ [DEBUG] Invite code is empty, showing error');
      setState(() {
        _validationResult = InviteValidationResult.failure(
          errorMessage: 'Please enter an invite code',
          errorType: InviteValidationError.invalidCode,
        );
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    print('🔍 [DEBUG] Set validation state to true');
    print('🔍 [DEBUG] About to call inviteRepository.validateInviteCode()');
    
    try {
      final inviteCode = _inviteCodeController.text.trim();
      print('🔍 [DEBUG] Calling validateInviteCode with code: "$inviteCode"');
      
      final inviteRepository = ref.read(inviteRepositoryProvider);
      final result = await inviteRepository.validateInviteCode(inviteCode);
      print('✅ [DEBUG] validateInviteCode completed successfully!');
      print('🔍 [DEBUG] Validation result:');
      print('   - isValid: ${result.isValid}');
      print('   - errorMessage: ${result.errorMessage}');
      print('   - errorType: ${result.errorType}');
      print('   - family: ${result.family?.name}');
      print('   - inviteId: ${result.inviteId}');

      if (!mounted) return;
      
      setState(() {
        _validationResult = result;
        _isValidating = false;
      });
      
      print('✅ [DEBUG] UI state updated successfully');
      
    } catch (e, stackTrace) {
      print('❌ [DEBUG] ===== UI VALIDATION ERROR =====');
      print('❌ [DEBUG] Error type: ${e.runtimeType}');
      print('❌ [DEBUG] Error message: $e');
      print('❌ [DEBUG] Error toString: $e');
      print('❌ [DEBUG] Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _validationResult = InviteValidationResult.failure(
          errorMessage: 'Error validating invite: $e',
          errorType: InviteValidationError.unknown,
        );
        _isValidating = false;
      });
      
      print('✅ [DEBUG] Error state set in UI');
    }
  }

  /// Accepts the invite and joins the family
  Future<void> _acceptInvite() async {
    if (_validationResult == null || !_validationResult!.isValid) return;

    setState(() {
      _isAccepting = true;
    });

    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final inviteRepository = ref.read(inviteRepositoryProvider);
      await inviteRepository.acceptInvite(
        inviteId: _validationResult!.inviteId!,
        uid: currentUser.uid,
        displayName: currentUser.displayName ?? 'New Member',
        email: currentUser.email ?? '',
      );

      setState(() {
        _isAccepting = false;
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the family!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to hub screen
        context.go('/hub');
      }
    } catch (e) {
      setState(() {
        _isAccepting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining family: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    if (difference < 365) return '${(difference / 30).round()} months ago';
    return '${(difference / 365).round()} years ago';
  }
}
