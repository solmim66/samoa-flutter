import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configurate per questa piattaforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmiQVohnPqVWvMpaba-aiGYI_jmd8sgCU',
    appId: '1:878255446461:web:5cf5e64700b5436ca7dad4',
    messagingSenderId: '878255446461',
    projectId: 'samoa-439f8',
    authDomain: 'samoa-439f8.firebaseapp.com',
    storageBucket: 'samoa-439f8.firebasestorage.app',
  );

  // ⚠️ Scaricare google-services.json da Firebase Console → progetto samoa-439f8
  // e posizionarlo in android/app/google-services.json

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_rb5Z_5G1dY_ycoWbi2FCmDDOH8Ggdg0',
    appId: '1:878255446461:android:e5b8c8c83611fb27a7dad4',
    messagingSenderId: '878255446461',
    projectId: 'samoa-439f8',
    storageBucket: 'samoa-439f8.firebasestorage.app',
  );

  // Poi sostituire i valori DA_INSERIRE con quelli del file.

  // ⚠️ Scaricare GoogleService-Info.plist da Firebase Console → progetto samoa-439f8

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8NU0cU5vc9DxhfJGraIjIABBv-zuFDik',
    appId: '1:878255446461:ios:9e4350f8def99201a7dad4',
    messagingSenderId: '878255446461',
    projectId: 'samoa-439f8',
    storageBucket: 'samoa-439f8.firebasestorage.app',
    iosClientId: '878255446461-bh763msre8qbdrt35119s2au9o89k9mp.apps.googleusercontent.com',
    iosBundleId: 'it.saladanza.samoaFlutter',
  );

  // e posizionarlo in ios/Runner/GoogleService-Info.plist
}