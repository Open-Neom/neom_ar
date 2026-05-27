import 'dart:async';
import 'dart:io';

import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import '../../domain/models/ar_enums.dart';
import '../../domain/models/ar_hit_result.dart';
import '../../domain/models/ar_measurement.dart';
import '../../domain/models/ar_plane.dart';
import '../../domain/models/ar_pose.dart';
import '../../domain/use_cases/ar_service.dart';

/// ARCore implementation of [ArService] for Android.
///
/// Uses arcore_flutter_plugin for plane detection and hit testing.
/// Note: ARCore doesn't have native Line or Text geometry, so we
/// use sphere chains for lines and report distances via UI overlay.
class ArcoreArService implements ArService {
  ArCoreController? _controller;
  final _planeController = StreamController<ArPlane>.broadcast();
  final _markers = <String, ArCoreNode>{};
  var _trackingState = ArTrackingState.notAvailable;
  int _markerCount = 0;

  @override
  ArPlatform get platform => ArPlatform.arcore;

  @override
  ArTrackingState get trackingState => _trackingState;

  @override
  Future<bool> isSupported() async => Platform.isAndroid;

  @override
  Stream<ArPlane> get onPlaneDetected => _planeController.stream;

  /// Initialize with an ArCoreController from the ArCoreView widget.
  void attachController(ArCoreController controller) {
    _controller = controller;
    _trackingState = ArTrackingState.normal;

    // Listen for plane detection
    controller.onPlaneDetected = (plane) {
      ArPlaneType type;
      switch (plane.type?.index) {
        case 0: type = ArPlaneType.horizontalUp;
        case 1: type = ArPlaneType.horizontalDown;
        case 2: type = ArPlaneType.vertical;
        default: type = ArPlaneType.unknown;
      }

      _planeController.add(ArPlane(
        id: 'plane_${plane.hashCode}',
        type: type,
        centerPose: ArPose.fromTranslationRotation(
          plane.centerPose!.translation,
          plane.centerPose!.rotation,
        ),
        extentX: plane.extendX ?? 0.0,
        extentZ: plane.extendZ ?? 0.0,
      ));
    };
  }

  @override
  Future<List<ArHitResult>> hitTest(double screenX, double screenY) async {
    // ARCore hit testing is handled via onPlaneTap callback.
    // This method collects results from the tap handler.
    // The caller should wire ArCoreView.onPlaneTap to feed results here.
    return [];
  }

  /// Process hit test results from ArCoreView.onPlaneTap.
  List<ArHitResult> processHitResults(List<ArCoreHitTestResult> results) {
    return results.map((r) {
      return ArHitResult(
        type: ArHitType.existingPlane,
        distance: r.distance,
        pose: ArPose.fromTranslationRotation(
          r.pose.translation,
          r.pose.rotation,
        ),
      );
    }).toList();
  }

  @override
  Future<String> addMarker(ArHitResult hitResult, {String? label}) async {
    if (_controller == null) return '';

    final id = 'marker_${_markerCount++}';
    final pos = hitResult.pose.position;

    final sphere = ArCoreSphere(
      radius: 0.008,
      materials: [ArCoreMaterial(color: Colors.greenAccent)],
    );

    final node = ArCoreNode(
      name: id,
      shape: sphere,
      position: Vector3(pos.x, pos.y, pos.z),
    );

    await _controller!.addArCoreNodeWithAnchor(node);
    _markers[id] = node;

    return id;
  }

  @override
  Future<void> removeMarker(String markerId) async {
    if (_controller == null) return;
    await _controller!.removeNode(nodeName: markerId);
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

    // ARCore has no Line primitive — render as sphere chain
    final posA = measurement.pointA.position;
    final posB = measurement.pointB.position;
    final steps = 20;

    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      final x = posA.x + (posB.x - posA.x) * t;
      final y = posA.y + (posB.y - posA.y) * t;
      final z = posA.z + (posB.z - posA.z) * t;

      final dot = ArCoreNode(
        name: '${markerIdA}_${markerIdB}_dot_$i',
        shape: ArCoreSphere(
          radius: 0.002,
          materials: [ArCoreMaterial(color: Colors.white70)],
        ),
        position: Vector3(x, y, z),
      );
      await _controller!.addArCoreNodeWithAnchor(dot);
    }
  }

  @override
  Future<void> dispose() async {
    await clearMarkers();
    _controller?.dispose();
    await _planeController.close();
  }
}
