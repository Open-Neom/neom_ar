import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import '../controllers/ar_measure_controller.dart';

/// Bottom panel showing the current measurement and dimension assignment.
class MeasurementPanel extends StatelessWidget {
  final ArMeasureController controller;

  const MeasurementPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final measurement = controller.currentMeasurement.value;
      if (measurement == null) return const SizedBox();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Distance display
            Text(
              measurement.formattedDistance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Assign to dimension buttons
            Text('arAssignTo'.tr,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _assignButton(
                  context,
                  'X (${'arWidth'.tr})',
                  Icons.swap_horiz,
                  controller.roomWidth.value != null,
                  controller.assignToWidth,
                ),
                _assignButton(
                  context,
                  'Y (${'arDepth'.tr})',
                  Icons.straight,
                  controller.roomDepth.value != null,
                  controller.assignToDepth,
                ),
                _assignButton(
                  context,
                  'Z (${'arHeight'.tr})',
                  Icons.height,
                  controller.roomHeight.value != null,
                  controller.assignToHeight,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _assignButton(
    BuildContext context,
    String label,
    IconData icon,
    bool assigned,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16, color: assigned ? Colors.green : Colors.white),
      label: Text(label, style: TextStyle(
        color: assigned ? Colors.green : Colors.white,
        fontSize: 12,
      )),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: assigned ? Colors.green : Colors.white38),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      onPressed: onTap,
    );
  }
}
