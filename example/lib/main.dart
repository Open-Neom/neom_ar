import 'package:flutter/material.dart';
import 'package:neom_ar/ui/pages/ar_measure_page.dart';
import 'package:sint/sint.dart';

void main() {
  // Pre-load default translations for example showcase
  _initTranslations();
  runApp(const NeomArExampleApp());
}

void _initTranslations() {
  final Map<String, String> es = {
    'arMeasureTitle': 'Escáner de Sala AR',
    'arReset': 'Reiniciar',
    'arCameraView': 'Vista de Cámara AR Activa',
    'arIntegrationNote': 'Apunta a superficies para detectar planos y medir',
    'arStartMeasuring': 'Iniciar Medición',
    'arAssignTo': 'Asignar a dimensión de sala',
    'arWidth': 'Ancho',
    'arDepth': 'Largo',
    'arHeight': 'Alto',
    'arSendToLevitation': 'Enviar a Levitación',
    'arPlanes': 'Planos Detectados',
    'arReady': 'Listo para medir',
    'arScanning': 'Escaneando...',
    'arTapFirstPoint': 'Toca un plano para el primer punto',
    'arTapSecondPoint': 'Toca otro plano para el segundo punto',
    'arMeasured': 'Medido',
    'arNotSupported': 'Dispositivo No Compatible',
    'arNotSupportedDesc': 'Este dispositivo no soporta ARKit ni ARCore.',
    'arManualInput': 'Entrada Manual',
  };

  final Map<String, String> en = {
    'arMeasureTitle': 'AR Room Scanner',
    'arReset': 'Reset',
    'arCameraView': 'AR Camera View Active',
    'arIntegrationNote': 'Point camera at surfaces to detect planes and measure',
    'arStartMeasuring': 'Start Measuring',
    'arAssignTo': 'Assign to room dimension',
    'arWidth': 'Width',
    'arDepth': 'Depth',
    'arHeight': 'Height',
    'arSendToLevitation': 'Send to Levitation',
    'arPlanes': 'Planes Detected',
    'arReady': 'Ready to measure',
    'arScanning': 'Scanning...',
    'arTapFirstPoint': 'Tap a plane for first point',
    'arTapSecondPoint': 'Tap another plane for second point',
    'arMeasured': 'Measured',
    'arNotSupported': 'Device Not Supported',
    'arNotSupportedDesc': 'This device does not support ARKit or ARCore.',
    'arManualInput': 'Manual Input',
  };

  Sint.addTranslations({
    'es': es,
    'en': en,
  });
  Sint.locale = const Locale('es');
}

class NeomArExampleApp extends StatelessWidget {
  const NeomArExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'neom_ar Showcase',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        useMaterial3: true,
      ),
      home: const ArMeasurePage(),
    );
  }
}
