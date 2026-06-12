import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  static const String devProjectId = 'very-simple-diary-dev';

  // Configs for Firebase Emulators
  static String get firestoreHost {
    if (kIsWeb) return 'localhost';
    // When debugging on an Android Emulator, localhost maps to 10.0.2.2
    return Platform.isAndroid ? '10.0.2.2' : 'localhost';
  }

  static int get firestorePort => 8080;

  static String get authHost {
    if (kIsWeb) return 'localhost';
    return Platform.isAndroid ? '10.0.2.2' : 'localhost';
  }

  static int get authPort => 9099;

  static bool get useEmulators => kDebugMode;
}
