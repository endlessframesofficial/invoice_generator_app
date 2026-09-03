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
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCOkUYvm20xAGGl7zHO0Y8s33V7dhy-LsY',
    appId: '1:315790762482:web:d8b93f3ad3ad2b59d94b6b',
    messagingSenderId: '315790762482',
    projectId: 'billingbook-app-ajith',
    authDomain: 'billingbook-app-ajith.firebaseapp.com',
    storageBucket: 'billingbook-app-ajith.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOkUYvm20xAGGl7zHO0Y8s33V7dhy-LsY',
    appId: '1:315790762482:android:d8b93f3ad3ad2b59d94b6b',
    messagingSenderId: '315790762482',
    projectId: 'billingbook-app-ajith',
    storageBucket: 'billingbook-app-ajith.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOkUYvm20xAGGl7zHO0Y8s33V7dhy-LsY',
    appId: '1:315790762482:ios:d8b93f3ad3ad2b59d94b6b',
    messagingSenderId: '315790762482',
    projectId: 'billingbook-app-ajith',
    storageBucket: 'billingbook-app-ajith.firebasestorage.app',
    iosBundleId: 'com.example.invoiceGeneratorApp',
  );
}
