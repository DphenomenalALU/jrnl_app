import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_env.dart';
import '../env/app_flavor.dart';
import '../routing/app_router.dart';
import '../routing/router_refresh_notifier.dart';

final appFlavorProvider = Provider<AppFlavor>((ref) {
  throw UnimplementedError('appFlavorProvider must be overridden in bootstrap.');
});

final appEnvProvider = Provider<AppEnv>((ref) {
  final flavor = ref.watch(appFlavorProvider);
  return appEnvForFlavor(flavor);
});

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = RouterRefreshNotifier(auth.authStateChanges());
  final router = createAppRouter(
    refreshListenable: refresh,
    isSignedIn: () => auth.currentUser != null,
  );
  ref.onDispose(router.dispose);
  ref.onDispose(refresh.dispose);
  return router;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

abstract interface class ProfileRepository {
  String getCurrentUserFirstName();
}

class InMemoryProfileRepository implements ProfileRepository {
  const InMemoryProfileRepository();

  @override
  String getCurrentUserFirstName() => 'Joshua';
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return const InMemoryProfileRepository();
});
