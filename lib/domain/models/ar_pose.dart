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

  static double _finite(double v, [double fallback = 0.0]) =>
      v.isFinite ? v : fallback;

  static Quaternion _sanitizeQuaternion(Quaternion q) {
    if (!q.x.isFinite ||
        !q.y.isFinite ||
        !q.z.isFinite ||
        !q.w.isFinite ||
        q.length2 <= 1e-12 ||
        !q.length2.isFinite) {
      return Quaternion.identity();
    }
    return q;
  }

  /// Create from ARKit Matrix4 worldTransform.
  factory ArPose.fromMatrix4(Matrix4 transform) {
    final col3 = transform.getColumn(3);
    final rotMatrix = transform.getRotation();
    final hasNonFiniteRot = rotMatrix.storage.any((v) => !v.isFinite);
    return ArPose(
      position: Vector3(
        _finite(col3.x),
        _finite(col3.y),
        _finite(col3.z),
      ),
      rotation: hasNonFiniteRot
          ? Quaternion.identity()
          : _sanitizeQuaternion(Quaternion.fromRotation(rotMatrix)),
    );
  }

  /// Create from ARCore translation + rotation.
  factory ArPose.fromTranslationRotation(
    Vector3 translation,
    Vector4 rotationVec,
  ) {
    return ArPose(
      position: Vector3(
        _finite(translation.x),
        _finite(translation.y),
        _finite(translation.z),
      ),
      rotation: _sanitizeQuaternion(
        Quaternion(
          rotationVec.x,
          rotationVec.y,
          rotationVec.z,
          rotationVec.w,
        ),
      ),
    );
  }

  /// Distance to another pose in meters.
  double distanceTo(ArPose other) {
    final d = position.distanceTo(other.position);
    return d.isFinite && d >= 0 ? d : 0.0;
  }

  /// Midpoint between this pose and another.
  Vector3 midpointTo(ArPose other) {
    final mid = (position + other.position) * 0.5;
    return Vector3(_finite(mid.x), _finite(mid.y), _finite(mid.z));
  }

  @override
  String toString() =>
      'ArPose(${position.x.toStringAsFixed(3)}, ${position.y.toStringAsFixed(3)}, ${position.z.toStringAsFixed(3)})';
}
