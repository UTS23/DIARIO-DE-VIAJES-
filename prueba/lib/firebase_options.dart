import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
    apiKey: 'AIzaSyBZeKyvVjdK1JU3El1YGl70T0TQ56gKdYE',
    appId: '1:36648132416:web:6a34a4eb8a875078cb64a5',
    messagingSenderId: '36648132416',
    projectId: 'prueba-39135',
    authDomain: 'prueba-39135.firebaseapp.com',
    storageBucket: 'prueba-39135.appspot.com',
    measurementId: 'G-2W3DZJWTRX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlQ-jAmeg4-tKCN-kFoad77xudz1-A6XM',
    appId: '1:36648132416:android:883b2182c84876d8cb64a5',
    messagingSenderId: '36648132416',
    projectId: 'prueba-39135',
    storageBucket: 'prueba-39135.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4fZWV5RoM3Pq4ZwfstdQ1oUriQo6Vuqk',
    appId: '1:36648132416:ios:e7ea299b671eabbecb64a5',
    messagingSenderId: '36648132416',
    projectId: 'prueba-39135',
    storageBucket: 'prueba-39135.appspot.com',
    iosBundleId: 'com.example.prueba',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC4fZWV5RoM3Pq4ZwfstdQ1oUriQo6Vuqk',
    appId: '1:36648132416:ios:e7ea299b671eabbecb64a5',
    messagingSenderId: '36648132416',
    projectId: 'prueba-39135',
    storageBucket: 'prueba-39135.appspot.com',
    iosBundleId: 'com.example.prueba',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBZeKyvVjdK1JU3El1YGl70T0TQ56gKdYE',
    appId: '1:36648132416:web:2183ae28d287f0dbcb64a5',
    messagingSenderId: '36648132416',
    projectId: 'prueba-39135',
    authDomain: 'prueba-39135.firebaseapp.com',
    storageBucket: 'prueba-39135.appspot.com',
    measurementId: 'G-BYKXWBENHP',
  );
}
