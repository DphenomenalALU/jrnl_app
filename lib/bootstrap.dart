import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/core/env/app_flavor.dart';
import 'src/app/bootstrap_app.dart';

Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(BootstrapApp(flavor: flavor));
}
