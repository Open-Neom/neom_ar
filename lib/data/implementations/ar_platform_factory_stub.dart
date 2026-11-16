import '../../domain/use_cases/ar_service.dart';
import '../../platform/stub/stub_ar_service.dart';

/// Web / non-IO fallback factory for [ArService].
class ArPlatformFactory {
  /// Create the platform-appropriate AR service.
  static ArService create() => StubArService();

  /// Whether AR is available on this platform.
  static bool get isAvailable => false;

  /// Human-readable platform name.
  static String get platformName => 'Web (no AR)';
}
