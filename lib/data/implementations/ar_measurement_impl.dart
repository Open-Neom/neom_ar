import '../../domain/models/ar_measurement.dart';
import '../../domain/use_cases/ar_measurement_service.dart';

/// In-memory measurement tracking for AR sessions.
class ArMeasurementImpl implements ArMeasurementService {
  final _measurements = <ArMeasurement>[];
  ArMeasurement? _width;
  ArMeasurement? _depth;
  ArMeasurement? _height;

  @override
  List<ArMeasurement> get measurements => List.unmodifiable(_measurements);

  @override
  ArRoomMeasurement get roomMeasurement => ArRoomMeasurement(
    lengthX: _width,
    lengthY: _depth,
    lengthZ: _height,
  );

  @override
  void addMeasurement(ArMeasurement measurement) {
    _measurements.add(measurement);
  }

  @override
  void setWidth(ArMeasurement measurement) {
    _width = measurement;
    addMeasurement(measurement);
  }

  @override
  void setDepth(ArMeasurement measurement) {
    _depth = measurement;
    addMeasurement(measurement);
  }

  @override
  void setHeight(ArMeasurement measurement) {
    _height = measurement;
    addMeasurement(measurement);
  }

  @override
  void clear() {
    _measurements.clear();
    _width = null;
    _depth = null;
    _height = null;
  }

  @override
  bool get isRoomComplete => _width != null && _depth != null && _height != null;
}
