import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fam_sync/core/di/di.dart';
import 'package:fam_sync/firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';

class AppBootstrapper {
  AppBootstrapper();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _initializeFirebase();
    _initializeTimezoneData();
    await _initializeLocalNotifications();

    registerDependencies();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Try default initialization (Android/iOS when google-services are present)
      await Firebase.initializeApp();
    } catch (e) {
      // Fallback to options-based initialization (requires generated firebase_options.dart)
      try {
        // ignore: avoid_dynamic_calls
        final options = (DefaultFirebaseOptions as dynamic).currentPlatform as FirebaseOptions;
        await Firebase.initializeApp(options: options);
      } catch (_) {
        // Swallow: app runs in limited mode until configured
        if (kDebugMode) debugPrint('Firebase not configured yet; continuing without it.');
      }
    }

    // Configure Firestore for offline-first where available
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {
      // Ignore if Firestore not available
    }
  }

  void _initializeTimezoneData() {
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // Safe to ignore if already initialized
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    try {
      await _notifications.initialize(initSettings);
    } catch (_) {
      // Non-fatal during bootstrap
    }
  }
}


