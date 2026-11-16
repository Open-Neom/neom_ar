import 'package:neom_core/ui/deferred_loader.dart';
import 'package:sint/sint.dart';

import 'ui/pages/ar_measure_page.dart' deferred as measure;

class ArRoutes {
  /// Optional route invoked when exporting room measurements or opening manual input.
  /// Host apps (e.g. Cyberneom) can leave the default `'/levitation'` or set a custom route;
  /// standalone apps without that route fall back to popping with the measured payload.
  static String? defaultExportRoute = '/levitation';

  static final routes = <SintPage>[
    SintPage(
      name: '/ar/measure',
      page: () => DeferredLoader(
        measure.loadLibrary,
        () => measure.ArMeasurePage(exportRoute: defaultExportRoute),
      ),
      transition: Transition.fadeIn,
    ),
  ];
}
