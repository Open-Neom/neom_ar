import 'ar_pose.dart';

/// A distance measurement between two AR points.
class ArMeasurement {
  final ArPose pointA;
  final ArPose pointB;
  final DateTime timestamp;
  final String? label;

  ArMeasurement({
    required this.pointA,
    required this.pointB,
    DateTime? timestamp,
    this.label,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Distance in meters.
  double get distanceM => pointA.distanceTo(pointB);

  /// Distance in centimeters.
  double get distanceCm => distanceM * 100;

  /// Formatted distance string.
  String get formattedDistance {
    if (distanceM >= 1.0) {
      return '${distanceM.toStringAsFixed(2)} m';
    }
    return '${distanceCm.toStringAsFixed(1)} cm';
  }

  /// Midpoint between the two points.
  get midpoint => pointA.midpointTo(pointB);

  Map<String, dynamic> toJson() => {
    'distanceM': distanceM,
    'label': label,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// A complete room measurement with up to 3 dimensions.
class ArRoomMeasurement {
  final ArMeasurement? lengthX;  // width
  final ArMeasurement? lengthY;  // depth
  final ArMeasurement? lengthZ;  // height
  final DateTime timestamp;

  ArRoomMeasurement({
    this.lengthX,
    this.lengthY,
    this.lengthZ,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether all 3 dimensions have been measured.
  bool get isComplete => lengthX != null && lengthY != null && lengthZ != null;

  /// Room dimensions in meters.
  double get width => lengthX?.distanceM ?? 0;
  double get depth => lengthY?.distanceM ?? 0;
  double get height => lengthZ?.distanceM ?? 0;

  /// Estimated volume in m³.
  double get volume => width * depth * height;

  Map<String, dynamic> toJson() => {
    'width': width,
    'depth': depth,
    'height': height,
    'volume': volume,
    'timestamp': timestamp.toIso8601String(),
  };
}
