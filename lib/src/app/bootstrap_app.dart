import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/di/providers.dart';
import '../core/env/app_env.dart';
import '../core/env/app_flavor.dart';
import '../core/presentation/theme/app_colors.dart';
import '../core/presentation/theme/app_text_styles.dart';
import '../core/services/app_prefs.dart';
import 'jrnl_app.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key, required this.flavor});

  final AppFlavor flavor;

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<(SharedPreferences,)> _initFuture;

  static var _firebaseConfigured = false;

  static void _configureFirebase({required AppEnv env}) {
    if (_firebaseConfigured) return;
    _firebaseConfigured = true;

    if (!env.useFirebaseEmulators) return;

    final host = env.emulatorHost;

    FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
  }

  @override
  void initState() {
    super.initState();
    final env = appEnvForFlavor(widget.flavor);
    _initFuture =
        Future.wait([
          Firebase.initializeApp(),
          SharedPreferences.getInstance(),
        ]).then((results) {
          _configureFirebase(env: env);
          return (results[1] as SharedPreferences,);
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(SharedPreferences,)>(
      future: _initFuture.timeout(const Duration(seconds: 20)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BootstrapError(error: snapshot.error),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: _BootstrapLoading(),
          );
        }
        final prefs = snapshot.data!.$1;
        return ProviderScope(
          overrides: [
            appFlavorProvider.overrideWithValue(widget.flavor),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const JrnlApp(),
        );
      },
    );
  }
}

class _BootstrapLoading extends StatelessWidget {
  const _BootstrapLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Startup error',
                style: AppTextStyles.playfair(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Firebase failed to initialize.\n\n$error',
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Checklist:\n'
                '- `ios/Runner/GoogleService-Info.plist` exists\n'
                '- plist is included in Runner target membership\n'
                '- bundle id in plist matches the app\n'
                '- run `cd ios && pod install` after `flutter pub get`',
                style: AppTextStyles.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
