// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyD0E8mgNiSwXVPrNQV67gQKZmoOX2xgUSg',
    appId: '1:950680291615:web:4479d401f08630562d882a',
    messagingSenderId: '950680291615',
    projectId: 'consumeraffairs-9eb55',
    authDomain: 'consumeraffairs-9eb55.firebaseapp.com',
    storageBucket: 'consumeraffairs-9eb55.firebasestorage.app',
    measurementId: 'G-9WDCG04WWV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCE-mlv8E4Le9I8ZDe9h-n8cDGZnEG2tlg',
    appId: '1:950680291615:android:2f8e528c3922928f2d882a',
    messagingSenderId: '950680291615',
    projectId: 'consumeraffairs-9eb55',
    storageBucket: 'consumeraffairs-9eb55.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASJGuCjBbz3r2D2wZfx9zEylhc8ev9Ekw',
    appId: '1:950680291615:ios:5fe933957a64b0622d882a',
    messagingSenderId: '950680291615',
    projectId: 'consumeraffairs-9eb55',
    storageBucket: 'consumeraffairs-9eb55.firebasestorage.app',
    iosBundleId: 'com.example.cunsumerAffairsApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyASJGuCjBbz3r2D2wZfx9zEylhc8ev9Ekw',
    appId: '1:950680291615:ios:5fe933957a64b0622d882a',
    messagingSenderId: '950680291615',
    projectId: 'consumeraffairs-9eb55',
    storageBucket: 'consumeraffairs-9eb55.firebasestorage.app',
    iosBundleId: 'com.example.cunsumerAffairsApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD0E8mgNiSwXVPrNQV67gQKZmoOX2xgUSg',
    appId: '1:950680291615:web:e431d88e184371f32d882a',
    messagingSenderId: '950680291615',
    projectId: 'consumeraffairs-9eb55',
    authDomain: 'consumeraffairs-9eb55.firebaseapp.com',
    storageBucket: 'consumeraffairs-9eb55.firebasestorage.app',
    measurementId: 'G-V617YECNBK',
  );
}
