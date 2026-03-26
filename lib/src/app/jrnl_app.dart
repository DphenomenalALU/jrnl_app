import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/presentation/theme/app_colors.dart';

class JrnlApp extends ConsumerStatefulWidget {
  const JrnlApp({super.key});

  @override
  ConsumerState<JrnlApp> createState() => _JrnlAppState();
}

class _JrnlAppState extends ConsumerState<JrnlApp> {
  ProviderSubscription? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = ref.listenManual(firebaseUserChangesProvider, (prev, next) {
      final user = next.valueOrNull;
      if (user == null) return;

      final displayName = (user.displayName?.trim().isNotEmpty ?? false)
          ? user.displayName!.trim()
          : _displayNameFromEmail(user.email) ?? 'Friend';

      unawaited(
        ref.read(usersRepositoryProvider).upsertUserProfile(
              uid: user.uid,
              displayName: displayName,
              photoUrl: user.photoURL,
            ),
      );
    });
  }

  @override
  void dispose() {
    _authSub?.close();
    super.dispose();
  }

  String? _displayNameFromEmail(String? email) {
    if (email == null) return null;
    final at = email.indexOf('@');
    if (at <= 0) return null;
    return email.substring(0, at);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final env = ref.watch(appEnvProvider);
    return MaterialApp.router(
      title: env.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        splashColor: AppColors.primary.withValues(alpha: 0.06),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
      ),
      routerConfig: router,
    );
  }
}
