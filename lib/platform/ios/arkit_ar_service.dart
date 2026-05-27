import 'dart:async';
import 'dart:io';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../domain/models/ar_enums.dart';
import '../../domain/models/ar_hit_result.dart';
import '../../domain/models/ar_measurement.dart';
import '../../domain/models/ar_plane.dart';
import '../../domain/models/ar_pose.dart';
import '../../domain/use_cases/ar_service.dart';

/// ARKit implementation of [ArService] for iOS.
///
/// Uses arkit_plugin to provide plane detection, hit testing,
/// and 3D marker rendering via ARKit's SceneKit integration.
///
/// Distance measurement pattern ported from arkit_flutter_plugin
/// examples: measure_page.dart and distance_tracking_page.dart.
class ArkitArService implements ArService {
  ARKitController? _controller;
  final _planeController = StreamController<ArPlane>.broadcast();
  final _markers = <String, ARKitNode>{};
  var _trackingState = ArTrackingState.notAvailable;
  int _markerCount = 0;

  @override
  ArPlatform get platform => ArPlatform.arkit;

  @override
  ArTrackingState get trackingState => _trackingState;

  @override
  Future<bool> isSupported() async => Platform.isIOS;

  @override
  Stream<ArPlane> get onPlaneDetected => _planeController.stream;

  /// Initialize with an ARKitController from the ARKitSceneView widget.
  void attachController(ARKitController controller) {
    _controller = controller;
    _trackingState = ArTrackingState.normal;

    // Listen for plane anchors
    controller.onAddNodeForAnchor = (anchor) {
      if (anchor is ARKitPlaneAnchor) {
        final pose = ArPose.fromMatrix4(anchor.transform);
        _planeController.add(ArPlane(
          id: anchor.identifier,
          type: ArPlaneType.horizontalUp,
          centerPose: pose,
          extentX: anchor.extent.x,
          extentZ: anchor.extent.z,
        ));
      }
    };
  }

  @override
  Future<List<ArHitResult>> hitTest(double screenX, double screenY) async {
    if (_controller == null) return [];

    final results = await _controller!.performHitTest(
      x: screenX,
      y: screenY,
    );

    return results.map((r) {
      ArHitType type;
      switch (r.type) {
        case ARKitHitTestResultType.existingPlaneUsingExtent:
        case ARKitHitTestResultType.existingPlaneUsingGeometry:
          type = ArHitType.existingPlane;
        case ARKitHitTestResultType.estimatedHorizontalPlane:
          type = ArHitType.estimatedPlane;
        case ARKitHitTestResultType.featurePoint:
          type = ArHitType.featurePoint;
        default:
          type = ArHitType.unknown;
      }

      return ArHitResult(
        type: type,
        distance: r.distance,
        pose: ArPose.fromMatrix4(r.worldTransform),
        anchorId: r.anchor?.identifier,
      );
    }).toList();
  }

  @override
  Future<String> addMarker(ArHitResult hitResult, {String? label}) async {
    if (_controller == null) return '';

    final id = 'marker_${_markerCount++}';
    final pos = hitResult.pose.position;

    // Sphere marker at hit point
    final sphere = ARKitSphere(
      radius: 0.006,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(
            const Color(0xFF00FF00),
          ),
        ),
      ],
    );

    final node = ARKitNode(
      name: id,
      geometry: sphere,
      position: Vector3(pos.x, pos.y, pos.z),
    );

    await _controller!.add(node);
    _markers[id] = node;

    return id;
  }

  @override
  Future<void> removeMarker(String markerId) async {
    if (_controller == null) return;
    await _controller!.remove(markerId);
    _markers.remove(markerId);
  }

  @override
  Future<void> clearMarkers() async {
    for (final id in _markers.keys.toList()) {
      await removeMarker(id);
    }
  }

  @override
  Future<void> addDistanceLine(
    String markerIdA,
    String markerIdB,
    ArMeasurement measurement,
  ) async {
    if (_controller == null) return;

    final posA = measurement.pointA.position;
    final posB = measurement.pointB.position;

    // Line between points
    final line = ARKitLine(
      fromVector: Vector3(posA.x, posA.y, posA.z),
      toVector: Vector3(posB.x, posB.y, posB.z),
    );
    final lineNode = ARKitNode(
      name: '${markerIdA}_${markerIdB}_line',
      geometry: line,
    );
    await _controller!.add(lineNode);

    // Text label at midpoint
    final mid = measurement.midpoint;
    final text = ARKitText(
      text: measurement.formattedDistance,
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(const Color(0xFFFFFFFF)),
        ),
      ],
    );
    final textNode = ARKitNode(
      name: '${markerIdA}_${markerIdB}_text',
      geometry: text,
      position: Vector3(mid.x, mid.y + 0.02, mid.z),
      scale: Vector3.all(0.001),
    );
    await _controller!.add(textNode);
  }

  @override
  Future<void> dispose() async {
    await clearMarkers();
    _controller?.dispose();
    await _planeController.close();
  }
}
