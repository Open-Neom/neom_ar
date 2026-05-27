import 'dart:async';

import '../../domain/models/ar_enums.dart';
import '../../domain/models/ar_hit_result.dart';
import '../../domain/models/ar_measurement.dart';
import '../../domain/models/ar_plane.dart';
import '../../domain/use_cases/ar_service.dart';

/// Stub AR service for platforms without AR support (web, desktop).
///
/// Returns empty results and reports AR as unsupported.
class StubArService implements ArService {
  @override
  ArPlatform get platform => ArPlatform.none;

  @override
  ArTrackingState get trackingState => ArTrackingState.notAvailable;

  @override
  Future<bool> isSupported() async => false;

  @override
  Stream<ArPlane> get onPlaneDetected => const Stream.empty();

  @override
  Future<List<ArHitResult>> hitTest(double screenX, double screenY) async => [];

  @override
  Future<String> addMarker(ArHitResult hitResult, {String? label}) async => '';

  @override
  Future<void> removeMarker(String markerId) async {}

  @override
  Future<void> clearMarkers() async {}

  @override
  Future<void> addDistanceLine(
    String markerIdA,
    String markerIdB,
    ArMeasurement measurement,
  ) async {}

  @override
  Future<void> dispose() async {}
}
