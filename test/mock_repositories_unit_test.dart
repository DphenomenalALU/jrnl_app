import 'package:flutter_test/flutter_test.dart';

import 'package:jrnl_app/src/features/journal/data/mock_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';
import 'package:jrnl_app/src/features/leaderboard/data/mock_leaderboard_repository.dart';
import 'package:jrnl_app/src/features/users/data/mock_users_repository.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';

void main() {
  group('MockJournalEntriesRepository', () {
    test('create/update/delete emits changes', () async {
      final repo = MockJournalEntriesRepository();
      addTearDown(repo.dispose);

      final id = await repo.createEntry(
        mode: JournalEntryMode.text,
        promptText: 'P',
        bodyText: 'B',
      );
      final afterCreate = await repo.watchEntries().first;
      expect(afterCreate.map((e) => e.id), contains(id));

      await repo.updateEntryBody(entryId: id, bodyText: 'B2');
      await repo.updateEntryEvaluation(
        entryId: id,
        energyIndex: 1,
        moodIndex: 2,
        internalIndex: 3,
      );
      await repo.updateEntryStatus(entryId: id, status: EntryStatus.uploaded);
      await repo.updateEntryTranscript(entryId: id, transcript: 'T');
      await repo.saveInsight(entryId: id, insight: 'I');

      await repo.deleteEntry(id);
      final afterDelete = await repo.watchEntries().first;
      expect(afterDelete.map((e) => e.id), isNot(contains(id)));
    });
  });

  group('MockUsersRepository', () {
    test('upsert/updateProfile affects watchUser', () async {
      final repo = MockUsersRepository();
      addTearDown(repo.dispose);

      await repo.updateProfile(
        uid: 'u1',
        displayName: 'Name 1',
        bio: 'Bio',
        location: 'Loc',
        email: 'a@b.com',
      );
      final u1 = await repo.watchUser('u1').first;
      expect(u1?.displayName, 'Name 1');

      await repo.upsertUserProfile(uid: 'u1', displayName: 'Name 2');
      final u2 = await repo.watchUser('u1').first;
      expect(u2?.displayName, 'Name 2');
    });

    test('watchLeaderboard sorts by xpTotal and limits', () async {
      final repo = MockUsersRepository();
      addTearDown(repo.dispose);

      await repo.upsertUser(
        AppUser(
          uid: 'a',
          displayName: 'A',
          photoUrl: null,
          bio: null,
          location: null,
          xpTotal: 10,
          streakCount: 0,
          tier: null,
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      await repo.upsertUser(
        AppUser(
          uid: 'b',
          displayName: 'B',
          photoUrl: null,
          bio: null,
          location: null,
          xpTotal: 9999,
          streakCount: 0,
          tier: null,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final top2 = await repo.watchLeaderboard(limit: 2).first;
      expect(top2, hasLength(2));
      expect(top2.first.uid, 'b');
    });
  });

  group('MockLeaderboardRepository', () {
    test('fetchPage paginates using cursor', () async {
      final repo = MockLeaderboardRepository(totalUsers: 25);
      final first = await repo.fetchPage(limit: 10);
      expect(first.users, hasLength(10));
      expect(first.nextCursor, isNotNull);

      final second = await repo.fetchPage(limit: 10, cursor: first.nextCursor);
      expect(second.users, hasLength(10));
    });
  });
}
