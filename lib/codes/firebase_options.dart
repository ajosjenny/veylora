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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCjHOpOvSz711f5suoAzqbA8kAICnMUFB4',
    appId: '1:142088347841:web:c0e4d010b0a09556c0b440',
    messagingSenderId: '142088347841',
    projectId: 'veylora-4d7c6',
    authDomain: 'veylora-4d7c6.firebaseapp.com',
    storageBucket: 'veylora-4d7c6.firebasestorage.app',
    measurementId: 'G-YFC0P3SRNZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCHo3bgkROynZrGVCT2FIvZNyjkl14MOcA',
    appId: '1:142088347841:android:85f227597eb70a2dc0b440',
    messagingSenderId: '142088347841',
    projectId: 'veylora-4d7c6',
    storageBucket: 'veylora-4d7c6.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC767-0Duc13svn-gxhRBI4lWMJQc8E6H0',
    appId: '1:142088347841:ios:66013d92a9a8db82c0b440',
    messagingSenderId: '142088347841',
    projectId: 'veylora-4d7c6',
    storageBucket: 'veylora-4d7c6.firebasestorage.app',
    iosBundleId: 'com.example.veylora',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC767-0Duc13svn-gxhRBI4lWMJQc8E6H0',
    appId: '1:142088347841:ios:66013d92a9a8db82c0b440',
    messagingSenderId: '142088347841',
    projectId: 'veylora-4d7c6',
    storageBucket: 'veylora-4d7c6.firebasestorage.app',
    iosBundleId: 'com.example.veylora',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCjHOpOvSz711f5suoAzqbA8kAICnMUFB4',
    appId: '1:142088347841:web:4e50fec13230f333c0b440',
    messagingSenderId: '142088347841',
    projectId: 'veylora-4d7c6',
    authDomain: 'veylora-4d7c6.firebaseapp.com',
    storageBucket: 'veylora-4d7c6.firebasestorage.app',
    measurementId: 'G-EKEL96KE3R',
  );
}
