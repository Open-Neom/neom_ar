import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/use_cases/ar_service.dart';
import '../../platform/ios/arkit_ar_service.dart';
import '../../platform/android/arcore_ar_service.dart';
import '../../platform/stub/stub_ar_service.dart';

/// Factory that returns the correct AR service for the current platform.
class ArPlatformFactory {
  /// Create the platform-appropriate AR service.
  static ArService create() {
    if (kIsWeb) return StubArService();

    if (Platform.isIOS) return ArkitArService();
    if (Platform.isAndroid) return ArcoreArService();

    return StubArService();
  }

  /// Whether AR is available on this platform.
  static bool get isAvailable {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Human-readable platform name.
  static String get platformName {
    if (kIsWeb) return 'Web (no AR)';
    if (Platform.isIOS) return 'ARKit (iOS)';
    if (Platform.isAndroid) return 'ARCore (Android)';
    return 'Unsupported';
  }
}
