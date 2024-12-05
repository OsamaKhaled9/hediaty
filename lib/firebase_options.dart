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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCsd_BUZ9xdF1mBAJbpHrNKl03zM0bycGw',
    appId: '1:758951280645:web:808aade6670e627b871c6c',
    messagingSenderId: '758951280645',
    projectId: 'hediaty-92c6c',
    authDomain: 'hediaty-92c6c.firebaseapp.com',
    storageBucket: 'hediaty-92c6c.firebasestorage.app',
    measurementId: 'G-Y0RBJ0C5F7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoBugZe5PKvICV0LLNNE-aN1KVADNrDhU',
    appId: '1:758951280645:android:6a7021902a8e8a54871c6c',
    messagingSenderId: '758951280645',
    projectId: 'hediaty-92c6c',
    storageBucket: 'hediaty-92c6c.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCsd_BUZ9xdF1mBAJbpHrNKl03zM0bycGw',
    appId: '1:758951280645:web:5ee4deb13c061d43871c6c',
    messagingSenderId: '758951280645',
    projectId: 'hediaty-92c6c',
    authDomain: 'hediaty-92c6c.firebaseapp.com',
    storageBucket: 'hediaty-92c6c.firebasestorage.app',
    measurementId: 'G-47B1NQK3R4',
  );
}
