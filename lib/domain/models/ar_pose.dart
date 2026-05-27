import 'package:vector_math/vector_math_64.dart';

/// Unified 3D pose (position + rotation) across ARKit and ARCore.
///
/// ARKit returns Matrix4 worldTransform → extract column(3) for position.
/// ARCore returns Vector3 translation + Vector4 rotation directly.
/// This class normalizes both to the same representation.
class ArPose {
  final Vector3 position;    // world position in meters
  final Quaternion rotation;  // orientation

  const ArPose({required this.position, required this.rotation});

  /// Create from ARKit Matrix4 worldTransform.
  factory ArPose.fromMatrix4(Matrix4 transform) {
    final col3 = transform.getColumn(3);
    return ArPose(
      position: Vector3(col3.x, col3.y, col3.z),
      rotation: Quaternion.fromRotation(transform.getRotation()),
    );
  }

  /// Create from ARCore translation + rotation.
  factory ArPose.fromTranslationRotation(
    Vector3 translation,
    Vector4 rotationVec,
  ) {
    return ArPose(
      position: translation,
      rotation: Quaternion(rotationVec.x, rotationVec.y, rotationVec.z, rotationVec.w),
    );
  }

  /// Distance to another pose in meters.
  double distanceTo(ArPose other) => position.distanceTo(other.position);

  /// Midpoint between this pose and another.
  Vector3 midpointTo(ArPose other) => (position + other.position) * 0.5;

  @override
  String toString() =>
      'ArPose(${position.x.toStringAsFixed(3)}, ${position.y.toStringAsFixed(3)}, ${position.z.toStringAsFixed(3)})';
}
