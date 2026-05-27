import '../models/ar_measurement.dart';

/// Interface for AR-based distance and room measurements.
abstract class ArMeasurementService {
  /// All measurements taken in the current session.
  List<ArMeasurement> get measurements;

  /// Current room measurement progress.
  ArRoomMeasurement get roomMeasurement;

  /// Add a point-to-point measurement.
  void addMeasurement(ArMeasurement measurement);

  /// Set width (X dimension) from a measurement.
  void setWidth(ArMeasurement measurement);

  /// Set depth (Y dimension) from a measurement.
  void setDepth(ArMeasurement measurement);

  /// Set height (Z dimension) from a measurement.
  void setHeight(ArMeasurement measurement);

  /// Clear all measurements.
  void clear();

  /// Whether room measurement is complete (all 3 dimensions).
  bool get isRoomComplete;
}
