import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import '../../domain/models/ar_enums.dart';
import '../controllers/ar_measure_controller.dart';

/// Status bar showing AR tracking state, planes detected, and instructions.
class ArStatusBar extends StatelessWidget {
  final ArMeasureController controller;

  const ArStatusBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.measureState.value;
      final planes = controller.detectedPlanes.length;
      final message = controller.statusMessage.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // State indicator
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _stateColor(state),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.isNotEmpty ? message : _stateLabel(state),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              // Planes detected
              if (planes > 0) ...[
                const Icon(Icons.grid_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$planes ${'arPlanes'.tr}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Color _stateColor(ArMeasureState state) {
    switch (state) {
      case ArMeasureState.idle: return Colors.grey;
      case ArMeasureState.scanning: return Colors.yellow;
      case ArMeasureState.placingFirst: return Colors.orange;
      case ArMeasureState.placingSecond: return Colors.blue;
      case ArMeasureState.measured: return Colors.green;
    }
  }

  String _stateLabel(ArMeasureState state) {
    switch (state) {
      case ArMeasureState.idle: return 'arReady'.tr;
      case ArMeasureState.scanning: return 'arScanning'.tr;
      case ArMeasureState.placingFirst: return 'arTapFirstPoint'.tr;
      case ArMeasureState.placingSecond: return 'arTapSecondPoint'.tr;
      case ArMeasureState.measured: return 'arMeasured'.tr;
    }
  }
}
