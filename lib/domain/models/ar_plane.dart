import 'package:vector_math/vector_math_64.dart';

import 'ar_enums.dart';
import 'ar_pose.dart';

/// Normalized detected plane from ARKit or ARCore.
///
/// ARKit: ARKitPlaneAnchor with center, extent, transform.
/// ARCore: ArCorePlane with extendX, extendZ, centerPose.
class ArPlane {
  final String id;
  final ArPlaneType type;
  final ArPose centerPose;
  final double extentX;    // width in meters
  final double extentZ;    // depth in meters

  const ArPlane({
    required this.id,
    required this.type,
    required this.centerPose,
    required this.extentX,
    required this.extentZ,
  });

  /// Area of detected plane in m².
  double get area => extentX * extentZ;

  /// Center position in world space.
  Vector3 get center => centerPose.position;

  /// Whether this plane is large enough to be a wall/floor.
  bool get isSignificant => area > 0.5; // > 0.5 m²

  @override
  String toString() =>
      'ArPlane($id, ${type.name}, ${extentX.toStringAsFixed(2)}×${extentZ.toStringAsFixed(2)}m)';
}
