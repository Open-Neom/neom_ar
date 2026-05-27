/// AR platform and state enums.
library;

/// Which AR platform is active.
enum ArPlatform { arkit, arcore, none }

/// AR session tracking state.
enum ArTrackingState { notAvailable, limited, normal }

/// Type of detected plane.
enum ArPlaneType {
  horizontalUp,
  horizontalDown,
  vertical,
  unknown,
}

/// Type of hit test result, ordered by accuracy.
enum ArHitType {
  existingPlane,
  estimatedPlane,
  featurePoint,
  unknown,
}

/// State of a measurement session.
enum ArMeasureState {
  idle,
  scanning,
  placingFirst,
  placingSecond,
  measured,
}

/// Room scan progress.
enum ArScanPhase {
  notStarted,
  detectingFloor,
  detectingWalls,
  detectingCeiling,
  complete,
}
