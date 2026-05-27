import 'ar_enums.dart';
import 'ar_pose.dart';

/// Normalized hit test result from ARKit or ARCore.
///
/// ARKit: extracts distance and worldTransform → ArPose.
/// ARCore: extracts distance, translation, rotation → ArPose.
class ArHitResult {
  final ArHitType type;
  final double distance;   // meters from camera
  final ArPose pose;       // world space position + rotation
  final String? anchorId;  // optional anchor identifier

  const ArHitResult({
    required this.type,
    required this.distance,
    required this.pose,
    this.anchorId,
  });

  /// Position in world space.
  get position => pose.position;

  @override
  String toString() =>
      'ArHitResult(${type.name}, ${distance.toStringAsFixed(3)}m, $pose)';
}
