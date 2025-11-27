import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBdo9_tnPaekCVNOgWxyHYjtC_40JdRyJw', // CHANGE
    appId: '1:65621566562:web:2c2bbdbee3b9a2fa8b9d3b', // CHANGE
    messagingSenderId: '65621566562', // CHANGE
    projectId: 'planta-2025',
    authDomain: 'planta-2025.firebaseapp.com',
    storageBucket: 'planta-2025.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdo9_tnPaekCVNOgWxyHYjtC_40JdRyJw', // CHANGE
    appId: '1:65621566562:web:2c2bbdbee3b9a2fa8b9d3b', // CHANGE
    messagingSenderId: '65621566562', // CHANGE
    projectId: 'planta-2025',
    storageBucket: 'planta-2025.firebasestorage.app',
  );
}
