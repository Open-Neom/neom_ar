// Tests para `ArPose`, `ArMeasurement`, `ArRoomMeasurement`, `ArPlane`,
// `ArHitResult`, y los enums.

import 'package:flutter_test/flutter_test.dart';
import 'package:neom_ar/domain/models/ar_enums.dart';
import 'package:neom_ar/domain/models/ar_hit_result.dart';
import 'package:neom_ar/domain/models/ar_measurement.dart';
import 'package:neom_ar/domain/models/ar_plane.dart';
import 'package:neom_ar/domain/models/ar_pose.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('AR enums', () {
    test('ArPlatform tiene 3 valores', () {
      expect(ArPlatform.values, hasLength(3));
    });

    test('ArTrackingState tiene 3 valores', () {
      expect(ArTrackingState.values, hasLength(3));
    });

    test('ArPlaneType tiene 4 valores', () {
      expect(ArPlaneType.values, hasLength(4));
    });

    test('ArHitType tiene 4 valores', () {
      expect(ArHitType.values, hasLength(4));
    });

    test('ArMeasureState tiene 5 valores', () {
      expect(ArMeasureState.values, hasLength(5));
    });

    test('ArScanPhase tiene 5 valores', () {
      expect(ArScanPhase.values, hasLength(5));
    });
  });

  group('ArPose', () {
    test('constructor preserva position y rotation', () {
      final pose = ArPose(
        position: Vector3(1, 2, 3),
        rotation: Quaternion.identity(),
      );
      expect(pose.position.x, 1);
      expect(pose.position.y, 2);
      expect(pose.position.z, 3);
    });

    test('distanceTo calcula distancia euclidiana', () {
      final p1 = ArPose(position: Vector3(0, 0, 0), rotation: Quaternion.identity());
      final p2 = ArPose(position: Vector3(3, 4, 0), rotation: Quaternion.identity());
      // sqrt(3² + 4²) = 5
      expect(p1.distanceTo(p2), closeTo(5, 1e-9));
    });

    test('distanceTo: 1 metro en Z', () {
      final p1 = ArPose(position: Vector3(0, 0, 0), rotation: Quaternion.identity());
      final p2 = ArPose(position: Vector3(0, 0, 1), rotation: Quaternion.identity());
      expect(p1.distanceTo(p2), closeTo(1, 1e-9));
    });

    test('midpointTo: punto medio', () {
      final p1 = ArPose(position: Vector3(0, 0, 0), rotation: Quaternion.identity());
      final p2 = ArPose(position: Vector3(2, 4, 6), rotation: Quaternion.identity());
      final mid = p1.midpointTo(p2);
      expect(mid.x, 1);
      expect(mid.y, 2);
      expect(mid.z, 3);
    });

    test('toString incluye coordenadas con 3 decimales', () {
      final pose = ArPose(
        position: Vector3(1.234, 5.678, 9.876),
        rotation: Quaternion.identity(),
      );
      final str = pose.toString();
      expect(str, contains('1.234'));
      expect(str, contains('5.678'));
      expect(str, contains('9.876'));
    });
  });

  group('ArMeasurement', () {
    ArMeasurement build(double distance) => ArMeasurement(
      pointA: ArPose(position: Vector3(0, 0, 0), rotation: Quaternion.identity()),
      pointB: ArPose(position: Vector3(distance, 0, 0), rotation: Quaternion.identity()),
    );

    test('distanceM correcto', () {
      final m = build(2.5);
      expect(m.distanceM, closeTo(2.5, 1e-9));
    });

    test('distanceCm = distanceM * 100', () {
      final m = build(0.5);
      expect(m.distanceCm, closeTo(50, 1e-9));
    });

    test('formattedDistance: < 1m → cm', () {
      final m = build(0.5);
      expect(m.formattedDistance, contains('cm'));
      expect(m.formattedDistance, contains('50.0'));
    });

    test('formattedDistance: >= 1m → m', () {
      final m = build(2.5);
      expect(m.formattedDistance, contains('m'));
      expect(m.formattedDistance, contains('2.50'));
    });

    test('toJson incluye distanceM, label, timestamp', () {
      final m = ArMeasurement(
        pointA: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
        pointB: ArPose(position: Vector3(1, 0, 0), rotation: Quaternion.identity()),
        label: 'mesa',
      );
      final json = m.toJson();
      expect(json['distanceM'], closeTo(1, 1e-9));
      expect(json['label'], 'mesa');
      expect(json['timestamp'], isA<String>());
    });
  });

  group('ArRoomMeasurement', () {
    ArMeasurement makeMeasurement(double distance) => ArMeasurement(
      pointA: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
      pointB: ArPose(position: Vector3(distance, 0, 0), rotation: Quaternion.identity()),
    );

    test('isComplete: false con dimensión faltante', () {
      final r = ArRoomMeasurement(
        lengthX: makeMeasurement(3),
        lengthY: makeMeasurement(4),
        // sin lengthZ
      );
      expect(r.isComplete, isFalse);
    });

    test('isComplete: true con las 3 dimensiones', () {
      final r = ArRoomMeasurement(
        lengthX: makeMeasurement(3),
        lengthY: makeMeasurement(4),
        lengthZ: makeMeasurement(2.5),
      );
      expect(r.isComplete, isTrue);
    });

    test('volume = width × depth × height', () {
      final r = ArRoomMeasurement(
        lengthX: makeMeasurement(4),
        lengthY: makeMeasurement(5),
        lengthZ: makeMeasurement(3),
      );
      expect(r.volume, closeTo(60, 1e-9)); // 4 × 5 × 3 = 60 m³
    });

    test('dimensiones null devuelven 0', () {
      final r = ArRoomMeasurement();
      expect(r.width, 0);
      expect(r.depth, 0);
      expect(r.height, 0);
      expect(r.volume, 0);
    });
  });

  group('ArPlane', () {
    test('area = extentX × extentZ', () {
      final p = ArPlane(
        id: 'p1',
        type: ArPlaneType.horizontalUp,
        centerPose: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
        extentX: 2,
        extentZ: 3,
      );
      expect(p.area, 6);
    });

    test('isSignificant: area > 0.5', () {
      final small = ArPlane(
        id: 'small',
        type: ArPlaneType.horizontalUp,
        centerPose: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
        extentX: 0.5,
        extentZ: 0.5,
      ); // area 0.25
      final big = ArPlane(
        id: 'big',
        type: ArPlaneType.horizontalUp,
        centerPose: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
        extentX: 2,
        extentZ: 1,
      ); // area 2
      expect(small.isSignificant, isFalse);
      expect(big.isSignificant, isTrue);
    });

    test('center retorna posición del centerPose', () {
      final p = ArPlane(
        id: 'p1',
        type: ArPlaneType.vertical,
        centerPose: ArPose(position: Vector3(1, 2, 3), rotation: Quaternion.identity()),
        extentX: 1, extentZ: 1,
      );
      expect(p.center.x, 1);
      expect(p.center.y, 2);
      expect(p.center.z, 3);
    });

    test('toString incluye id, tipo, dimensiones', () {
      final p = ArPlane(
        id: 'plane-42',
        type: ArPlaneType.horizontalUp,
        centerPose: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
        extentX: 1.5, extentZ: 2.7,
      );
      final str = p.toString();
      expect(str, contains('plane-42'));
      expect(str, contains('horizontalUp'));
      expect(str, contains('1.50'));
      expect(str, contains('2.70'));
    });
  });

  group('ArHitResult', () {
    test('preserva los campos', () {
      final hit = ArHitResult(
        type: ArHitType.existingPlane,
        distance: 1.5,
        pose: ArPose(position: Vector3(1, 0, 0), rotation: Quaternion.identity()),
        anchorId: 'anchor-1',
      );
      expect(hit.type, ArHitType.existingPlane);
      expect(hit.distance, 1.5);
      expect(hit.anchorId, 'anchor-1');
    });

    test('toString incluye type, distancia, pose', () {
      final hit = ArHitResult(
        type: ArHitType.featurePoint,
        distance: 2.345,
        pose: ArPose(position: Vector3.zero(), rotation: Quaternion.identity()),
      );
      final str = hit.toString();
      expect(str, contains('featurePoint'));
      expect(str, contains('2.345'));
    });
  });
}
