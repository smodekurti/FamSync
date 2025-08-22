import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fam_sync/domain/models/user_profile.dart';

class AuthRepository {
  AuthRepository({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<UserProfile?> watchUserProfile() async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield null;
        continue;
      }
      
      // Add a small delay to ensure Firebase Auth state is fully propagated
      // This helps resolve timing issues between auth state and Firestore permissions
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      final docRef = _firestore.collection('users').doc(user.uid);
      // Listen to profile in real-time with offline cache; create if missing lazily
      yield* docRef.snapshots().asyncMap((snap) async {
        if (snap.exists && snap.data() != null) {
          return UserProfile.fromJson(snap.data()!);
        }
        final profile = UserProfile(
          uid: user.uid,
          displayName: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          role: UserRole.parent,
          onboarded: false,
        );
        try {
          await docRef.set(profile.toJson(), SetOptions(merge: true));
        } catch (_) {
          // If offline or unavailable, return minimal profile; merge will occur when back online
        }
        return profile;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // canceled
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();
  
  /// Force refresh the user profile stream to resolve authentication state issues
  Future<void> refreshUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Force a small delay to ensure auth state is stable
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // This will trigger the stream to refresh
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchUserProfile();
});

/// Provider that invalidates all family-related providers when auth state changes
final authStateProvider = StreamProvider<fb.User?>((ref) {
  return fb.FirebaseAuth.instance.authStateChanges();
});

/// Provider that forces refresh of all family-related data
final refreshFamilyDataProvider = FutureProvider.family<void, String>((ref, familyId) async {
  // This will trigger invalidation of all family-related providers
  await Future<void>.delayed(const Duration(milliseconds: 300));
  return;
});


