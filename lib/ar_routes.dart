import 'package:neom_core/ui/deferred_loader.dart';
import 'package:sint/sint.dart';

import 'ui/pages/ar_measure_page.dart' deferred as measure;

class ArRoutes {
  static final routes = <SintPage>[
    SintPage(
      name: '/ar/measure',
      page: () => DeferredLoader(
        measure.loadLibrary,
        () => measure.ArMeasurePage(),
      ),
      transition: Transition.fadeIn,
    ),
  ];
}
