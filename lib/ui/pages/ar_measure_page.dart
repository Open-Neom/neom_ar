import 'package:flutter/material.dart';
import 'package:sint/sint.dart';

import '../../domain/models/ar_enums.dart';
import '../controllers/ar_measure_controller.dart';
import '../widgets/ar_status_bar.dart';
import '../widgets/measurement_panel.dart';
import '../widgets/room_dimensions_card.dart';

/// AR measurement page — tap to measure distances in the real world.
///
/// Flow:
/// 1. Point camera at surfaces, wait for plane detection
/// 2. Tap first point → green marker appears
/// 3. Tap second point → line + distance label
/// 4. Assign measurement to Width, Depth, or Height
/// 5. When all 3 are assigned → can export to neom_levitation
class ArMeasurePage extends StatelessWidget {
  const ArMeasurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SintBuilder<ArMeasureController>(
      init: ArMeasureController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('arMeasureTitle'.tr),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.reset,
                tooltip: 'arReset'.tr,
              ),
            ],
          ),
          body: Obx(() {
            if (!controller.isArSupported.value) {
              return _buildUnsupportedView(context);
            }

            return Stack(
              children: [
                // AR camera view placeholder
                // In real integration, this would be ARKitSceneView or ArCoreView
                // wrapped with the platform-specific AR widget.
                Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_in_ar, size: 64,
                            color: Colors.white.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'arCameraView'.tr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'arIntegrationNote'.tr,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Status bar at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ArStatusBar(controller: controller),
                ),

                // Bottom panel
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current measurement
                      if (controller.currentMeasurement.value != null)
                        MeasurementPanel(controller: controller),

                      // Room dimensions
                      RoomDimensionsCard(controller: controller),
                    ],
                  ),
                ),
              ],
            );
          }),
          floatingActionButton: Obx(() {
            if (!controller.isArSupported.value) return const SizedBox();

            final state = controller.measureState.value;
            if (state == ArMeasureState.idle) {
              return FloatingActionButton.extended(
                icon: const Icon(Icons.play_arrow),
                label: Text('arStartMeasuring'.tr),
                onPressed: controller.startMeasuring,
              );
            }
            return const SizedBox();
          }),
        );
      },
    );
  }

  Widget _buildUnsupportedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.view_in_ar, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'arNotSupported'.tr,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'arNotSupportedDesc'.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text('arManualInput'.tr),
              onPressed: () => Sint.toNamed('/levitation'),
            ),
          ],
        ),
      ),
    );
  }
}
