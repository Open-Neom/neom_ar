import 'package:vector_math/vector_math_64.dart';

import 'ar_pose.dart';

/// A distance measurement between two AR points.
class ArMeasurement {
  final ArPose pointA;
  final ArPose pointB;
  final DateTime timestamp;
  final String? label;

  ArMeasurement({
    required this.pointA,
    required this.pointB,
    DateTime? timestamp,
    this.label,
  }) : timestamp = timestamp ?? DateTime.now();

  static final RegExp _controlOrBidi = RegExp(
    r'[\x00-\x1F\x7F-\x9F\u0085\u061C\u200B-\u200F\u2028-\u202E\u2060-\u2069\uFEFF]',
  );
  static final RegExp _llmArtifacts = RegExp(
    r'<\|(?:channel|turn)>\s*thought\b[\s\S]*?(?:<(?:channel|turn)\|>|$)|<\|tool_call>[\s\S]*?(?:<tool_call\|>|$)|<\s*(think|thought|memory_recall|system_context|auto_memory)\b[^>]*>[\s\S]*?(?:<\s*/\s*\1\s*>|$)|\[\s*(BIOCHIP|MEMORY_RECALL|SYSTEM_CONTEXT|AUTO_MEMORY)\b[^\]]*\][\s\S]*?\[\s*/\s*\2\b[^\]]*\]|<\|/?(?:turn|channel|tool_call|eot)\|?>?|<(?:turn|channel|tool_call|eot)\|>|<\s*/?\s*(?:think|thought|memory_recall|system_context|auto_memory)\b[^>]*>|\[\s*/?\s*(?:BIOCHIP|MEMORY_RECALL|SYSTEM_CONTEXT|AUTO_MEMORY)\b[^\]]*\]',
    caseSensitive: false,
  );
  static final RegExp _closingContent = RegExp(
    r'<\s*/\s*content\s*>',
    caseSensitive: false,
  );

  static String? _sanitizeLabel(String? raw) {
    if (raw == null) return null;
    final cleaned = raw
        .replaceAll(_llmArtifacts, ' ')
        .replaceAll(_closingContent, '[content_end]')
        .replaceAll(_controlOrBidi, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return null;
    if (cleaned.length <= 160) return cleaned;
    var end = 160;
    final lastCode = cleaned.codeUnitAt(end - 1);
    if (lastCode >= 0xD800 && lastCode <= 0xDBFF) end--;
    return end <= 0 ? null : cleaned.substring(0, end);
  }

  /// Distance in meters.
  double get distanceM {
    final d = pointA.distanceTo(pointB);
    return d.isFinite && d >= 0 ? d : 0.0;
  }

  /// Distance in centimeters.
  double get distanceCm {
    final cm = distanceM * 100;
    return cm.isFinite ? cm : 0.0;
  }

  /// Formatted distance string.
  String get formattedDistance {
    if (distanceM >= 1.0) {
      return '${distanceM.toStringAsFixed(2)} m';
    }
    return '${distanceCm.toStringAsFixed(1)} cm';
  }

  /// Midpoint between the two points.
  Vector3 get midpoint => pointA.midpointTo(pointB);

  Map<String, dynamic> toJson() => {
    'distanceM': distanceM,
    'label': _sanitizeLabel(label),
    'timestamp': timestamp.toIso8601String(),
  };
}

/// A complete room measurement with up to 3 dimensions.
class ArRoomMeasurement {
  final ArMeasurement? lengthX;  // width
  final ArMeasurement? lengthY;  // depth
  final ArMeasurement? lengthZ;  // height
  final DateTime timestamp;

  ArRoomMeasurement({
    this.lengthX,
    this.lengthY,
    this.lengthZ,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether all 3 dimensions have been measured.
  bool get isComplete => lengthX != null && lengthY != null && lengthZ != null;

  /// Room dimensions in meters.
  double get width => lengthX?.distanceM ?? 0;
  double get depth => lengthY?.distanceM ?? 0;
  double get height => lengthZ?.distanceM ?? 0;

  /// Estimated volume in m³.
  double get volume {
    final v = width * depth * height;
    return v.isFinite && v >= 0 ? v : 0.0;
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'depth': depth,
    'height': height,
    'volume': volume,
    'timestamp': timestamp.toIso8601String(),
  };
}
