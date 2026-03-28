import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../features/users/presentation/current_app_user_provider.dart';
import '../domain/journal_entry.dart';

/// Streams a single entry — used by AiInsightsScreen to react to status
/// transitions written by Cloud Functions (transcribing → done).
final insightsEntryProvider = StreamProvider.autoDispose
    .family<JournalEntry?, String>((ref, entryId) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref
          .watch(firebaseFirestoreProvider)
          .collection('users')
          .doc(uid)
          .collection('entries')
          .doc(entryId)
          .snapshots()
          .map((snap) {
            if (!snap.exists) return null;
            return JournalEntry.fromDoc(uid: uid, doc: snap);
          });
    });
