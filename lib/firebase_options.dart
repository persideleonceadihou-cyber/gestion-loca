import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDPrUSd_N_lNTX-9IneRj0BYiHS6Prf74k',
    appId: '1:822380501516:web:9272f837c6757517c76c29',
    messagingSenderId: '822380501516',
    projectId: 'gestion-locative-3f02c',
    authDomain: 'gestion-locative-3f02c.firebaseapp.com',
    storageBucket: 'gestion-locative-3f02c.firebasestorage.app',
    measurementId: 'G-HM1JXL1Y4C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYx3zFCVInMFGbBgJp2i4KTnngY059J4o',
    appId: '1:822380501516:android:a0a88f1ff1561b7fc76c29',
    messagingSenderId: '822380501516',
    projectId: 'gestion-locative-3f02c',
    storageBucket: 'gestion-locative-3f02c.firebasestorage.app',
  );
}
