import 'package:flutter_test/flutter_test.dart';
import 'package:neom_ar/data/implementations/ar_measurement_impl.dart';
import 'package:neom_ar/domain/models/ar_measurement.dart';
import 'package:neom_ar/domain/models/ar_pose.dart';
import 'package:neom_ar/ui/controllers/ar_measure_controller.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('Lote 86 — neom_ar uninitialized lifecycle, ring buffer & UTF-16 label hardening', () {
    test('ArMeasureController survives reset() and repeated onClose() before onInit()', () {
      final controller = ArMeasureController();
      expect(() => controller.reset(), returnsNormally);
      expect(() => controller.onClose(), returnsNormally);
      expect(() => controller.onClose(), returnsNormally);
    });

    test('ArMeasurementImpl caps history at maxMeasurements and ArMeasurement sanitizes UTF-16 labels', () {
      final store = ArMeasurementImpl();
      final p0 = ArPose(
        position: Vector3.zero(),
        rotation: Quaternion.identity(),
      );
      final p1 = ArPose(
        position: Vector3(1, 0, 0),
        rotation: Quaternion.identity(),
      );
      for (var i = 0; i < ArMeasurementImpl.maxMeasurements + 20; i++) {
        store.addMeasurement(ArMeasurement(pointA: p0, pointB: p1));
      }
      expect(
        store.measurements.length,
        equals(ArMeasurementImpl.maxMeasurements),
      );

      // Surrogate pair right at index 159 ('A' * 159 + '🔥') -> must not leave lone high surrogate
      final label = '${'A' * 159}🔥tail\u202E';
      final m = ArMeasurement(pointA: p0, pointB: p1, label: label);
      final sanitized = m.toJson()['label'] as String;
      expect(sanitized.length, equals(159));
      expect(sanitized, equals('A' * 159));
      expect(m.midpoint.x, closeTo(0.5, 1e-6));
    });
  });
}
