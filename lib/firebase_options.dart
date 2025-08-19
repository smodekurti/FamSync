import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDCaEEBiXVFFx3HDSrZMS9l9xJ5PByVD4U',
        appId: '1:797333682643:ios:23c0bd4614d656eccad726',
        messagingSenderId: '797333682643',
        projectId: 'famsync-91f49',
        storageBucket: 'famsync-91f49.firebasestorage.app',
        iosBundleId: 'com.example.famsync',
      );
    }
    if (Platform.isAndroid) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDCaEEBiXVFFx3HDSrZMS9l9xJ5PByVD4U',
        appId: '1:797333682643:android:af08c510764f1356cad726',
        messagingSenderId: '797333682643',
        projectId: 'famsync-91f49',
        storageBucket: 'famsync-91f49.firebasestorage.app',
      );
    }
    // Web (fallback when not running on iOS/Android)
    return const FirebaseOptions(
      apiKey: 'AIzaSyDCaEEBiXVFFx3HDSrZMS9l9xJ5PByVD4U',
      appId: '1:797333682643:web:6f0bf6c9cdbfabe6cad726',
      messagingSenderId: '797333682643',
      projectId: 'famsync-91f49',
      storageBucket: 'famsync-91f49.firebasestorage.app',
      authDomain: 'famsync-91f49.firebaseapp.com',
      measurementId: 'G-5ZB90DRYHH',
    );
  }
}


