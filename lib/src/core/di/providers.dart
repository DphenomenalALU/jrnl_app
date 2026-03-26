import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routing/app_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
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

