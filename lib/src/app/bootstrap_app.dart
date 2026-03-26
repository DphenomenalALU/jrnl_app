import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/env/app_flavor.dart';
import '../core/presentation/theme/app_colors.dart';
import '../core/presentation/theme/app_text_styles.dart';
import 'jrnl_app.dart';

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key, required this.flavor});

  final AppFlavor flavor;

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appFlavorProvider.overrideWithValue(widget.flavor),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
        ),
        home: FutureBuilder<void>(
          future: _initFuture.timeout(const Duration(seconds: 20)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _BootstrapError(error: snapshot.error);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const _BootstrapLoading();
            }
            return const JrnlApp();
          },
        ),
      ),
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

