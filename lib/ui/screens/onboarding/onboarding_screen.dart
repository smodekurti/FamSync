import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:fam_sync/data/family/family_repository.dart';
import 'package:fam_sync/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _familyName = TextEditingController();
  final TextEditingController _familyId = TextEditingController();
  String _role = 'parent';
  bool _busy = false;
  
  // Validation state
  bool _isValidatingName = false;
  String? _nameValidationError;
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    // Add listener for real-time name validation
    _familyName.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _familyName.removeListener(_onNameChanged);
    _familyName.dispose();
    _familyId.dispose();
    super.dispose();
  }

  /// Real-time name validation with debouncing
  void _onNameChanged() {
    final name = _familyName.text.trim();
    
    // Clear previous validation state
    setState(() {
      _nameValidationError = null;
      _isNameValid = false;
    });

    // Skip validation for empty names
    if (name.isEmpty) return;

    // Debounce validation to avoid excessive API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _familyName.text.trim() == name) {
        _validateFamilyName(name);
      }
    });
  }

  /// Validates the family name in real-time
  Future<void> _validateFamilyName(String name) async {
    if (!mounted) return;

    setState(() {
      _isValidatingName = true;
      _nameValidationError = null;
    });

    try {
      // Basic validation checks
      if (name.length < 2) {
        setState(() {
          _nameValidationError = 'Family name must be at least 2 characters long';
          _isNameValid = false;
        });
        return;
      }

      if (name.length > 50) {
        setState(() {
          _nameValidationError = 'Family name cannot exceed 50 characters';
          _isNameValid = false;
        });
        return;
      }

      // Check for valid characters
      final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_\.]+$');
      if (!validPattern.hasMatch(name)) {
        setState(() {
          _nameValidationError = 'Family name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
          _isNameValid = false;
        });
        return;
      }

      // If basic validation passes, mark as valid
      setState(() {
        _isNameValid = true;
        _nameValidationError = null;
      });

    } catch (e) {
      // If validation fails, show generic error
      setState(() {
        _nameValidationError = 'Could not validate family name';
        _isNameValid = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isValidatingName = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    final colors = context.colors;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to FamSync'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spaces.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.layout.isSmall ? 440 : 560,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome header
                Text(
                  'Create or Join Your Family',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spaces.sm),
                Text(
                  'Get started by creating a new family or joining an existing one',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spaces.xl),

                // Role selection
                Text(
                  'Choose Your Role',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: spaces.sm),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'parent',
                      label: Text('Parent'),
                      icon: Icon(Icons.family_restroom),
                    ),
                    ButtonSegment(
                      value: 'child',
                      label: Text('Child'),
                      icon: Icon(Icons.child_care),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                ),
                SizedBox(height: spaces.xl),

                // Create family section
                Card(
                  elevation: 2,
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
                              size: 24,
                            ),
                            SizedBox(width: spaces.sm),
                            Text(
                              'Create a New Family',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spaces.md),
                        Text(
                          'Start your family journey by creating a new household',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: spaces.md),
                        TextField(
                          controller: _familyName,
                          decoration: InputDecoration(
                            labelText: 'Family Name',
                            hintText: 'e.g., Smith Family, Johnson Household',
                            prefixIcon: Icon(Icons.home, color: colors.primary),
                            suffixIcon: _isValidatingName
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                    ),
                                  )
                                : _isNameValid
                                    ? Icon(Icons.check_circle, color: colors.primary)
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(spaces.sm),
                            ),
                            errorText: _nameValidationError,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_nameValidationError != null) ...[
                          SizedBox(height: spaces.sm),
                          Text(
                            _nameValidationError!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.error,
                            ),
                          ),
                        ],
                        SizedBox(height: spaces.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy || !_isNameValid || _familyName.text.trim().isEmpty
                                ? null
                                : _createFamily,
                            icon: Icon(Icons.add),
                            label: Text('Create Family'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              padding: EdgeInsets.symmetric(vertical: spaces.md),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spaces.xl),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.outline)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spaces.md),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.outline)),
                  ],
                ),
                SizedBox(height: spaces.xl),

                // Join family section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(spaces.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.link,
                              color: colors.secondary,
                              size: 24,
                            ),
                            SizedBox(width: spaces.sm),
                            Text(
                              'Join Existing Family',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spaces.md),
                        Text(
                          'Join a family using an invite code or family ID',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: spaces.md),
                        TextField(
                          controller: _familyId,
                          decoration: InputDecoration(
                            labelText: 'Family ID or Invite Code',
                            hintText: 'Enter the code shared by your family',
                            prefixIcon: Icon(Icons.key, color: colors.secondary),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(spaces.sm),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: spaces.md),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy || _familyId.text.trim().isEmpty
                                ? null
                                : _joinFamily,
                            icon: Icon(Icons.login),
                            label: Text('Join Family'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.secondary,
                              side: BorderSide(color: colors.secondary),
                              padding: EdgeInsets.symmetric(vertical: spaces.md),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createFamily() async {
    setState(() => _busy = true);
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You are not signed in.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final familyName = _familyName.text.trim();
      
      // Final validation before creating
      if (!_isNameValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fix the family name validation errors before creating.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final id = await ref
          .read(familyRepositoryProvider)
          .createFamily(name: familyName, ownerUid: uid);
      
      await _updateUser(uid: uid, familyId: id, role: _role, onboarded: true);
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Family "$familyName" created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      context.go('/hub');
    } catch (e) {
      if (!mounted) return;
      
      // Handle specific validation errors
      String errorMessage = 'Could not create family';
      if (e.toString().contains('already exists')) {
        errorMessage = 'A family with this name already exists. Please choose a different name.';
      } else if (e.toString().contains('must be at least')) {
        errorMessage = 'Family name is too short. Please use at least 2 characters.';
      } else if (e.toString().contains('cannot exceed')) {
        errorMessage = 'Family name is too long. Please use 50 characters or less.';
      } else if (e.toString().contains('can only contain')) {
        errorMessage = 'Family name contains invalid characters. Please use only letters, numbers, spaces, hyphens, underscores, and dots.';
      } else {
        errorMessage = 'Could not create family: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _joinFamily() async {
    setState(() => _busy = true);
    try {
      final uid = fb.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You are not signed in.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      final familyId = _familyId.text.trim();
      await ref
          .read(familyRepositoryProvider)
          .joinFamily(familyId: familyId, uid: uid, role: _role);
      await _updateUser(
        uid: uid,
        familyId: familyId,
        role: _role,
        onboarded: true,
      );
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully joined family!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      context.go('/hub');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not join family: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateUser({
    required String uid,
    required String familyId,
    required String role,
    required bool onboarded,
  }) async {
    // Lightweight write via Firestore (direct inline to avoid extra service now)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'familyId': familyId,
      'role': role == 'parent' ? 'parent' : 'child',
      'onboarded': onboarded,
    }, SetOptions(merge: true));
    // Navigation handled in calling methods
  }
}
