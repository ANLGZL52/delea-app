// KENDİ PROJEN İÇİN: `cd mobile` → `dart pub global activate flutterfire_cli` → `flutterfire configure`
// Aşağıdaki değerler FlutterFire e2e test projesinden türetilmiştir; uygulama açılır, üretimde mutlaka kendi Firebase projeni bağla.
//
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXFCDl4D0WA5GpEnK1OSH3VB-6bOHx4wo',
    appId: '1:121352951764:web:5af2a957bdc4ea48c22841',
    messagingSenderId: '121352951764',
    projectId: 'dla-plus',
    authDomain: 'dla-plus.firebaseapp.com',
    storageBucket: 'dla-plus.firebasestorage.app',
    measurementId: 'G-BX94EH48FB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDmXgn6TM148VxgPqwiTvaUKG8nGQ0mWsw',
    appId: '1:121352951764:android:6f1711e780d14695c22841',
    messagingSenderId: '121352951764',
    projectId: 'dla-plus',
    storageBucket: 'dla-plus.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDCHBFny6FY9xuEUrhLv1lDiRnp9DTVYuQ',
    appId: '1:121352951764:ios:92f1cffaba046d5fc22841',
    messagingSenderId: '121352951764',
    projectId: 'dla-plus',
    storageBucket: 'dla-plus.firebasestorage.app',
    iosBundleId: 'com.delea.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDooSUGSf63Ghq02_iIhtnmwMDs4HlWS6c',
    appId: '1:406099696497:ios:acd9c8e17b5e620e3574d0',
    messagingSenderId: '406099696497',
    projectId: 'flutterfire-e2e-tests',
    databaseURL:
        'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
    androidClientId:
        '406099696497-tvtvuiqogct1gs1s6lh114jeps7hpjm5.apps.googleusercontent.com',
    iosClientId:
        '406099696497-taeapvle10rf355ljcvq5dt134mkghmp.apps.googleusercontent.com',
    iosBundleId: 'io.flutter.plugins.firebase.tests',
  );
}