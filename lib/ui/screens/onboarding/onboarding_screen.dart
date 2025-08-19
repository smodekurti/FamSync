import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:fam_sync/data/auth/auth_repository.dart';
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

  @override
  void dispose() {
    _familyName.dispose();
    _familyId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spaces = context.spaces;
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spaces.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.layout.isSmall ? 440 : 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Create or Join Family', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: spaces.md),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'parent', label: Text('Parent'), icon: Icon(Icons.family_restroom)),
                    ButtonSegment(value: 'child', label: Text('Child'), icon: Icon(Icons.child_care)),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                ),
                SizedBox(height: spaces.lg),
                Text('Create a new family', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: spaces.sm),
                TextField(
                  controller: _familyName,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Family name'),
                ),
                SizedBox(height: spaces.sm),
                FilledButton(
                  onPressed: _busy || _familyName.text.trim().isEmpty ? null : _createFamily,
                  child: _busy
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create'),
                ),
                SizedBox(height: spaces.xl),
                Text('Or join with Family ID', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: spaces.sm),
                TextField(
                  controller: _familyId,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Family ID'),
                ),
                SizedBox(height: spaces.sm),
                OutlinedButton(
                  onPressed: _busy || _familyId.text.trim().isEmpty ? null : _joinFamily,
                  child: const Text('Join'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are not signed in.')));
        return;
      }
      final id = await ref.read(familyRepositoryProvider).createFamily(name: _familyName.text.trim(), ownerUid: uid);
      await _updateUser(uid: uid, familyId: id, role: _role, onboarded: true);
      if (!mounted) return;
      context.go('/hub');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not create family: $e')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are not signed in.')));
        return;
      }
      final familyId = _familyId.text.trim();
      await ref.read(familyRepositoryProvider).joinFamily(familyId: familyId, uid: uid, role: _role);
      await _updateUser(uid: uid, familyId: familyId, role: _role, onboarded: true);
      if (!mounted) return;
      context.go('/hub');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not join family: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _updateUser({required String uid, required String familyId, required String role, required bool onboarded}) async {
    // Lightweight write via Firestore (direct inline to avoid extra service now)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'familyId': familyId,
      'role': role == 'parent' ? 'parent' : 'child',
      'onboarded': onboarded,
    }, SetOptions(merge: true));
    // Navigation handled in calling methods
  }
}


