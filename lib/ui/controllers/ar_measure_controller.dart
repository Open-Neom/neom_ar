import 'package:sint/sint.dart';

import '../../data/implementations/ar_measurement_impl.dart';
import '../../data/implementations/ar_platform_factory.dart';
import '../../domain/models/ar_enums.dart';
import '../../domain/models/ar_hit_result.dart';
import '../../domain/models/ar_measurement.dart';
import '../../domain/models/ar_plane.dart';
import '../../domain/use_cases/ar_service.dart';

/// Controller for AR measurement sessions.
///
/// Manages the measurement flow: tap to place points, calculate
/// distance, assign to room dimensions (width/depth/height).
class ArMeasureController extends SintController {
  late final ArService arService;
  final measureService = ArMeasurementImpl();

  // State
  final measureState = ArMeasureState.idle.obs;
  final scanPhase = ArScanPhase.notStarted.obs;
  final currentMeasurement = Rxn<ArMeasurement>();
  final detectedPlanes = <ArPlane>[].obs;
  final isArSupported = false.obs;
  final statusMessage = ''.obs;

  // Measurement points
  ArHitResult? _firstPoint;
  String? _firstMarkerId;

  // Room
  final roomWidth = Rxn<double>();
  final roomDepth = Rxn<double>();
  final roomHeight = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    arService = ArPlatformFactory.create();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    isArSupported.value = await arService.isSupported();
    if (isArSupported.value) {
      arService.onPlaneDetected.listen((plane) {
        if (plane.isSignificant && !detectedPlanes.any((p) => p.id == plane.id)) {
          detectedPlanes.add(plane);
        }
      });
    }
  }

  /// Start a new measurement session.
  void startMeasuring() {
    measureState.value = ArMeasureState.scanning;
    statusMessage.value = 'arScanSurfaces'.tr;
  }

  /// Handle a tap on the AR view.
  Future<void> onTap(double x, double y) async {
    final results = await arService.hitTest(x, y);
    if (results.isEmpty) return;

    // Use the most accurate hit result
    final best = results.first;

    switch (measureState.value) {
      case ArMeasureState.scanning:
      case ArMeasureState.placingFirst:
        // Place first point
        _firstPoint = best;
        _firstMarkerId = await arService.addMarker(best, label: 'A');
        measureState.value = ArMeasureState.placingSecond;
        statusMessage.value = 'arTapSecondPoint'.tr;

      case ArMeasureState.placingSecond:
        // Place second point and calculate distance
        final secondMarkerId = await arService.addMarker(best, label: 'B');

        final measurement = ArMeasurement(
          pointA: _firstPoint!.pose,
          pointB: best.pose,
        );

        await arService.addDistanceLine(
          _firstMarkerId!,
          secondMarkerId,
          measurement,
        );

        currentMeasurement.value = measurement;
        measureService.addMeasurement(measurement);
        measureState.value = ArMeasureState.measured;
        statusMessage.value = measurement.formattedDistance;

      case ArMeasureState.measured:
        // Reset for next measurement
        await arService.clearMarkers();
        _firstPoint = null;
        _firstMarkerId = null;
        measureState.value = ArMeasureState.placingFirst;
        statusMessage.value = 'arTapFirstPoint'.tr;
        // Recurse to place the first point of the new measurement
        await onTap(x, y);

      default:
        break;
    }
  }

  /// Process ARCore hit results (called from ArCoreView.onPlaneTap).
  void onArcoreHitResults(List<ArHitResult> results) {
    if (results.isEmpty) return;
    onTap(0, 0); // Coordinates not needed, results are pre-computed
  }

  /// Assign current measurement to a room dimension.
  void assignToWidth() {
    final m = currentMeasurement.value;
    if (m == null) return;
    measureService.setWidth(m);
    roomWidth.value = m.distanceM;
  }

  void assignToDepth() {
    final m = currentMeasurement.value;
    if (m == null) return;
    measureService.setDepth(m);
    roomDepth.value = m.distanceM;
  }

  void assignToHeight() {
    final m = currentMeasurement.value;
    if (m == null) return;
    measureService.setHeight(m);
    roomHeight.value = m.distanceM;
  }

  /// Whether all room dimensions have been assigned.
  bool get isRoomComplete => measureService.isRoomComplete;

  /// Get the completed room measurement.
  ArRoomMeasurement get roomMeasurement => measureService.roomMeasurement;

  /// Reset everything.
  void reset() {
    arService.clearMarkers();
    measureService.clear();
    _firstPoint = null;
    _firstMarkerId = null;
    currentMeasurement.value = null;
    roomWidth.value = null;
    roomDepth.value = null;
    roomHeight.value = null;
    measureState.value = ArMeasureState.idle;
    statusMessage.value = '';
  }

  @override
  void onClose() {
    arService.dispose();
    super.onClose();
  }
}
