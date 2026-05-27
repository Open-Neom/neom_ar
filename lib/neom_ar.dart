/// NeomAR — Cross-platform AR module for Cyberneom.
///
/// Wraps ARKit (iOS) and ARCore (Android) behind a unified interface.
/// Provides distance measurement, plane detection, and room scanning
/// for acoustic levitation chamber analysis.
///
/// Architecture:
/// - ArService interface → ArkitArService (iOS) / ArcoreArService (Android) / StubArService (web)
/// - ArPlatformFactory selects the correct implementation at runtime
/// - ArMeasureController manages the measurement flow via SintController
/// - ArMeasurePage provides the UI with AR camera view + dimension assignment
library;

// ============ Domain Models ============
export 'domain/models/ar_enums.dart';
export 'domain/models/ar_hit_result.dart';
export 'domain/models/ar_measurement.dart';
export 'domain/models/ar_plane.dart';
export 'domain/models/ar_pose.dart';

// ============ Service Interfaces ============
export 'domain/use_cases/ar_measurement_service.dart';
export 'domain/use_cases/ar_service.dart';

// ============ Platform Implementations ============
export 'platform/ios/arkit_ar_service.dart';
export 'platform/android/arcore_ar_service.dart';
export 'platform/stub/stub_ar_service.dart';

// ============ Data Implementations ============
export 'data/implementations/ar_measurement_impl.dart';
export 'data/implementations/ar_platform_factory.dart';

// ============ Routes ============
export 'ar_routes.dart';

// ============ Translations ============
export 'data/translations/ar_es_translations.dart';
export 'data/translations/ar_en_translations.dart';
export 'data/translations/ar_fr_translations.dart';
export 'data/translations/ar_de_translations.dart';
