# neom_ar

A highly optimized, cross-platform Augmented Reality (AR) library for Flutter. `neom_ar` encapsulates ARKit (iOS) and ARCore (Android) behind a unified, pure-Dart interface, providing real-time surface detection, distance measurement, and 3D room volume scanning.

It is designed to seamlessly integrate with neighboring acoustic levitation systems (such as `neom_levitation`) by scanning spatial physical bounds and automatically calculating room dimensions.

---

## Features

- 📱 **Cross-Platform AR Support**: Automatically mounts `ARKitSceneView` on iOS and `ArCoreView` on Android.
- 📐 **High-Precision Distance Measurement**: Tap two points in real-world space to measure distances with millimetric accuracy.
- 🚪 **Volumetric Room Scanner**: Interactively measure and assign Width (X), Depth (Y), and Height (Z) dimensions to scan complete physical chambers.
- 🧪 **Automatic Volume Calculation**: Computes chamber volumes in cubic meters ($m^3$) on-the-fly.
- 📡 **Levitation Bridge**: Built-in deferred routing and state transmission to export measured bounds directly to acoustic simulation environments.
- 💻 **Offline Stubs**: Includes a robust mock stub fallback allowing developers to test features on desktop or non-AR hardware seamlessly.

---

## Installation

Add `neom_ar` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  neom_ar: ^1.0.0
```

---

## Quick Start

### 1. Configure Platforms

Ensure your target platforms meet the following requirements:
- **iOS**: iOS 11.3+ and ARKit-compatible device. Add `NSCameraUsageDescription` to your `Info.plist`.
- **Android**: Android SDK 24+ and Google Play Services for AR installed.

### 2. Basic Usage

Use the high-level `ArMeasurePage` directly, or instantiate the `ArMeasureController` for custom interfaces:

```dart
import 'package:flutter/material.dart';
import 'package:neom_ar/lib/ui/pages/ar_measure_page.dart';
import 'package:sint/sint.dart';

void main() {
  runApp(
    MaterialApp(
      home: const ArMeasurePage(),
    ),
  );
}
```

---

## API Architecture

The package exposes the following main domain boundaries:

- **`ArPose`**: Represents a 3D coordinate point $(x, y, z)$ with orientation quaternion quaternions.
- **`ArPlane`**: Holds dimensions, types, and areas of detected real-world surfaces.
- **`ArMeasurement`**: Wraps two points, computing physical distance and returning formatted strings (e.g. `24.5 cm` or `1.85 m`).
- **`ArService`**: General abstraction interface implementing platform-specific controllers for ARCore and ARKit.
