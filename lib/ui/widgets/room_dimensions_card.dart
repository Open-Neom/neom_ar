import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import '../controllers/ar_measure_controller.dart';

/// Card showing the current room dimension assignments.
///
/// When all 3 dimensions are assigned, shows "Send to Levitation" button
/// to export the measurements to neom_levitation.
class RoomDimensionsCard extends StatelessWidget {
  final ArMeasureController controller;

  const RoomDimensionsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final w = controller.roomWidth.value;
      final d = controller.roomDepth.value;
      final h = controller.roomHeight.value;

      if (w == null && d == null && h == null) return const SizedBox();

      return Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.isRoomComplete
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.white24,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dimDisplay('X', w, Icons.swap_horiz),
                _dimDisplay('Y', d, Icons.straight),
                _dimDisplay('Z', h, Icons.height),
              ],
            ),

            if (controller.isRoomComplete) ...[
              const SizedBox(height: 8),
              Text(
                'Vol: ${controller.roomMeasurement.volume.toStringAsFixed(2)} m³',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.waves),
                  label: Text('arSendToLevitation'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final room = controller.roomMeasurement;
                    // Navigate to levitation with measured dimensions
                    Sint.toNamed('/levitation', arguments: {
                      'lengthX': room.width,
                      'lengthY': room.depth,
                      'lengthZ': room.height,
                      'source': 'ar_measurement',
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _dimDisplay(String axis, double? value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: value != null ? Colors.green : Colors.white30, size: 20),
        const SizedBox(height: 4),
        Text(
          value != null ? '${value.toStringAsFixed(2)} m' : '—',
          style: TextStyle(
            color: value != null ? Colors.white : Colors.white30,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(axis, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
