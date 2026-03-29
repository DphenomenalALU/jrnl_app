import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import 'current_app_user_provider.dart';

/// Cross-device onboarding completion flag.
///
/// Stored on the user's public profile doc at `users/{uid}`:
/// - `onboardingComplete` (bool)
/// - `onboardingCompletedAt` (timestamp, optional)
final onboardingCompleteProvider = StreamProvider.autoDispose<bool>((ref) {
  if (ref.watch(useMockDataProvider)) return Stream.value(true);

  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(false);

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('users').doc(uid).snapshots().map((snap) {
    final data = snap.data();
    final complete = (data?['onboardingComplete'] as bool?) ?? false;
    return complete;
  });
});

final setOnboardingCompleteProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    final firestore = ref.read(firebaseFirestoreProvider);
    await firestore.collection('users').doc(uid).set(<String, Object?>{
      'uid': uid,
      'onboardingComplete': true,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  };
});
