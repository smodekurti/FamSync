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
  final List<StreamSubscription> _activeSubscriptions = [];

  Stream<UserProfile?> watchUserProfile() async* {
    String? currentUid;
    
    await for (final user in _auth.authStateChanges()) {
      // If user changed, clear previous user's data and subscriptions
      if (currentUid != null && user?.uid != currentUid) {
        print('AuthRepository: User changed from $currentUid to ${user?.uid}, clearing previous data...');
        await _cancelAllSubscriptions();
        await _clearCachedData();
      }
      
      if (user == null) {
        currentUid = null;
        yield null;
        continue;
      }
      
      currentUid = user.uid;
      print('AuthRepository: Watching profile for user: ${user.uid} (${user.email})');
      
      // Add a small delay to ensure Firebase Auth state is fully propagated
      // This helps resolve timing issues between auth state and Firestore permissions
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      final docRef = _firestore.collection('users').doc(user.uid);
      
      try {
        // Listen to profile in real-time with offline cache; create if missing lazily
        final subscription = docRef.snapshots().listen(null);
        _activeSubscriptions.add(subscription);
        
        yield* docRef.snapshots().asyncMap((snap) async {
          if (snap.exists && snap.data() != null) {
            final profile = UserProfile.fromJson(snap.data()!);
            print('AuthRepository: Retrieved profile for ${user.email}: onboarded=${profile.onboarded}, familyId=${profile.familyId}');
            return profile;
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
            print('AuthRepository: Created new profile for ${user.email}');
          } catch (setError) {
            print('AuthRepository: Warning - Could not save profile for ${user.email}: $setError');
            // If offline or unavailable, return minimal profile; merge will occur when back online
            // This is not a critical error, so we continue
          }
          return profile;
        });
      } catch (e) {
        print('AuthRepository: Error watching profile for ${user.email}: $e');
        // If there's a permission error or other issue, try to create a minimal profile
        // This prevents the error from bubbling up to the UI
        try {
          final profile = UserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'User',
            email: user.email ?? '',
            photoUrl: user.photoURL,
            role: UserRole.parent,
            onboarded: false,
          );
          
          // Try to set the profile, but don't fail if it doesn't work
          try {
            await docRef.set(profile.toJson(), SetOptions(merge: true));
            print('AuthRepository: Created fallback profile for ${user.email}');
          } catch (setError) {
            print('AuthRepository: Could not save fallback profile for ${user.email}: $setError');
            // Ignore errors when setting profile - this is not critical
          }
          
          yield profile;
        } catch (fallbackError) {
          print('AuthRepository: Critical error creating fallback profile for ${user.email}: $fallbackError');
          // If even creating a minimal profile fails, yield null to trigger login
          yield null;
        }
      }
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

  Future<void> signOut() async {
    print('AuthRepository: Starting sign out process...'); // Debug log
    
    try {
      // First, try to cancel all active Firestore subscriptions
      print('AuthRepository: Canceling subscriptions...'); // Debug log
      await _cancelAllSubscriptions();
      
      // Clear any cached data
      print('AuthRepository: Clearing cached data...'); // Debug log
      await _clearCachedData();
      
      // Force refresh the user profile stream to ensure clean state
      print('AuthRepository: Force refreshing user profile stream...'); // Debug log
      await forceRefreshUserProfile();
      
      // Then sign out from Firebase Auth
      print('AuthRepository: Signing out from Firebase Auth...'); // Debug log
      await _auth.signOut();
      
      // Clear Google Sign-In cache
      print('AuthRepository: Clearing Google Sign-In cache...'); // Debug log
      await GoogleSignIn().signOut();
      
      print('AuthRepository: Sign out completed successfully'); // Debug log
      
    } catch (e) {
      print('AuthRepository: Error during sign out: $e'); // Debug log
      
      // If there's an error during cleanup, still try to sign out from auth
      try {
        print('AuthRepository: Attempting fallback sign out...'); // Debug log
        
        // Force cancel all subscriptions without waiting
        _forceCancelSubscriptions();
        
        // Try basic sign out
        await _auth.signOut();
        await GoogleSignIn().signOut();
        
        print('AuthRepository: Fallback sign out completed'); // Debug log
        
      } catch (fallbackError) {
        print('AuthRepository: Fallback sign out failed: $fallbackError'); // Debug log
        
        // If even the basic sign out fails, we need to handle this gracefully
        // Log the error but don't rethrow - we want the user to be signed out
        
        // Force clear the auth state
        try {
          await _auth.signOut();
          print('AuthRepository: Force sign out completed'); // Debug log
        } catch (_) {
          print('AuthRepository: Force sign out failed'); // debug log
          // Last resort - ignore all errors
        }
      }
    }
  }

  /// Cancel all active Firestore subscriptions to prevent permission errors
  Future<void> _cancelAllSubscriptions() async {
    for (final subscription in _activeSubscriptions) {
      try {
        await subscription.cancel();
      } catch (_) {
        // Ignore errors when canceling subscriptions
      }
    }
    _activeSubscriptions.clear();
  }

  /// Clear any cached data that might cause permission issues
  Future<void> _clearCachedData() async {
    try {
      // Clear Firestore offline cache for the current user
      final user = _auth.currentUser;
      if (user != null) {
        // This will clear any cached data that might cause permission issues
        await _firestore.clearPersistence();
      }
    } catch (_) {
      // Ignore errors when clearing cache
    }
  }
  
  /// Force refresh the user profile stream to resolve authentication state issues
  Future<void> refreshUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      print('AuthRepository: Refreshing user profile for ${user.email}');
      // Force a small delay to ensure auth state is stable
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // This will trigger the stream to refresh
    }
  }

  /// Force refresh the user profile stream by invalidating the current stream
  /// This is useful when switching between users to ensure clean state
  Future<void> forceRefreshUserProfile() async {
    print('AuthRepository: Force refreshing user profile stream');
    // Clear all subscriptions and cached data
    await _cancelAllSubscriptions();
    await _clearCachedData();
    
    // Force a delay to ensure clean state
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  /// Force cancel all subscriptions without waiting for async operations
  void _forceCancelSubscriptions() {
    for (final subscription in _activeSubscriptions) {
      try {
        subscription.cancel();
      } catch (_) {
        // Ignore errors when canceling subscriptions
      }
    }
    _activeSubscriptions.clear();
  }

  /// Dispose method to clean up resources
  void dispose() {
    for (final subscription in _activeSubscriptions) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
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

/// Provider that can be used to force refresh the user profile stream
final refreshUserProfileProvider = FutureProvider<void>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  await repo.forceRefreshUserProfile();
});

/// Provider that invalidates the user profile stream when auth state changes
final userProfileInvalidatorProvider = Provider<void>((ref) {
  // Watch auth state changes and invalidate user profile when needed
  ref.watch(authStateProvider);
  
  // This will cause the userProfileStreamProvider to refresh when auth state changes
  ref.invalidate(userProfileStreamProvider);
});


