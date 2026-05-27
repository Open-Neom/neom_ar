import '../models/ar_enums.dart';
import '../models/ar_hit_result.dart';
import '../models/ar_measurement.dart';
import '../models/ar_plane.dart';

/// Unified AR service interface — abstracts ARKit and ARCore.
abstract class ArService {
  /// Which platform is active.
  ArPlatform get platform;

  /// Whether AR is supported on this device.
  Future<bool> isSupported();

  /// Current tracking state.
  ArTrackingState get trackingState;

  /// Stream of detected planes.
  Stream<ArPlane> get onPlaneDetected;

  /// Perform a hit test at screen coordinates (normalized 0-1).
  Future<List<ArHitResult>> hitTest(double screenX, double screenY);

  /// Add a measurement marker at a hit result position.
  Future<String> addMarker(ArHitResult hitResult, {String? label});

  /// Remove a marker by its ID.
  Future<void> removeMarker(String markerId);

  /// Remove all markers.
  Future<void> clearMarkers();

  /// Add a distance line between two markers.
  Future<void> addDistanceLine(String markerIdA, String markerIdB, ArMeasurement measurement);

  /// Clean up resources.
  Future<void> dispose();
}
