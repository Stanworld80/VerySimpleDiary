// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Default [FirebaseOptions] for use with [Firebase.initializeApp].
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
      
      switch (appEnv) {
        case 'staging':
          return const FirebaseOptions(
            apiKey: 'AIzaSyD5fzxnUKYHpiAkmyJDriDfA-NAYJaU_70',
            appId: '1:160188147811:web:9b894cf8ff08286eeb3056',
            messagingSenderId: '160188147811',
            projectId: 'stanverysimplediary-stg',
            authDomain: 'stanverysimplediary-stg.firebaseapp.com',
            storageBucket: 'stanverysimplediary-stg.firebasestorage.app',
          );
        case 'prod':
          // Placeholder config for prod, replace with actual prod keys if available
          return const FirebaseOptions(
            apiKey: 'AIzaSyPlaceholderProdApiKey',
            appId: '1:placeholder:web:prod',
            messagingSenderId: '1234567890',
            projectId: 'stanverysimplediary',
            authDomain: 'stanverysimplediary.firebaseapp.com',
            storageBucket: 'stanverysimplediary.firebasestorage.app',
          );
        case 'dev':
        default:
          return const FirebaseOptions(
            apiKey: 'AIzaSyBOXJjYtFicr9OiFlFx9XZjjAErV0hC_NY',
            appId: '1:634048753631:web:2e514d64870db15ec6de6a',
            messagingSenderId: '634048753631',
            projectId: 'stanverysimplediary-dev',
            authDomain: 'stanverysimplediary-dev.firebaseapp.com',
            storageBucket: 'stanverysimplediary-dev.firebasestorage.app',
          );
      }
    }
    
    // Returning null for native platforms to use standard google-services.json / GoogleService-Info.plist configuration
    return null;
  }

  static String? get googleClientId {
    if (kIsWeb) {
      const appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
      switch (appEnv) {
        case 'staging':
          return null; // Add staging client ID here if needed
        case 'prod':
          return null;
        case 'dev':
        default:
          return '634048753631-260r2820e8nf8ds8aeud24s22koftd4n.apps.googleusercontent.com';
      }
    }
    return null;
  }
}
