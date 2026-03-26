import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/di/providers.dart';
import 'src/core/env/app_flavor.dart';
import 'src/app/jrnl_app.dart';

Future<void> bootstrap({required AppFlavor flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        appFlavorProvider.overrideWithValue(flavor),
      ],
      child: const JrnlApp(),
    ),
  );
}
