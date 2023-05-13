// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOKB34X5bo3nfHPGvBpKgM28qJns56Q6E',
    appId: '1:902346825341:android:dcc6095cc022ed9d5f5b14',
    messagingSenderId: '902346825341',
    projectId: 't3myrkm',
    storageBucket: 't3myrkm.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBLw59mE2VSOADyRmhyhRFqowcrid9TDoA',
    appId: '1:902346825341:ios:3e4bc8e62c128d5f5f5b14',
    messagingSenderId: '902346825341',
    projectId: 't3myrkm',
    storageBucket: 't3myrkm.appspot.com',
    androidClientId: '902346825341-8s0vgs2eikpnldck2amdpn2obrnsfd62.apps.googleusercontent.com',
    iosClientId: '902346825341-pe3vbih94blhg8mttnqm2v9msuqilcm5.apps.googleusercontent.com',
    iosBundleId: 'com.ebtasm.sevenemirates',
  );
}