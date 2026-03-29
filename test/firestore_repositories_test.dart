import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jrnl_app/src/features/journal/data/firestore_journal_entries_repository.dart';
import 'package:jrnl_app/src/features/journal/domain/journal_entry.dart';
import 'package:jrnl_app/src/features/leaderboard/data/firestore_leaderboard_repository.dart';
import 'package:jrnl_app/src/features/prompts/data/firestore_prompts_repository.dart';
import 'package:jrnl_app/src/features/prompts/domain/prompt.dart';
import 'package:jrnl_app/src/features/users/data/firestore_users_repository.dart';
import 'package:jrnl_app/src/features/users/domain/app_user.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockFirebaseAuth auth;
  late _MockUser user;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = _MockFirebaseAuth();
    user = _MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => auth.currentUser).thenReturn(user);
  });

  group('FirestoreUsersRepository', () {
    late FirestoreUsersRepository repo;

    setUp(() {
      repo = FirestoreUsersRepository(firestore);
    });

    test('getUser returns null when missing', () async {
      expect(await repo.getUser('missing'), isNull);
    });

    test('getUser maps document to AppUser', () async {
      await firestore.collection('users').doc('u1').set({
        'displayName': 'Alice',
        'xpTotal': 10,
        'streakCount': 2,
        'tier': 'T1',
      });
      final u = await repo.getUser('u1');
      expect(u, isNotNull);
      expect(u!.uid, 'u1');
      expect(u.displayName, 'Alice');
      expect(u.xpTotal, 10);
    });

    test('upsertUser merges public fields', () async {
      final appUser = AppUser(
        uid: 'u1',
        displayName: 'Bob',
        xpTotal: 5,
        streakCount: 1,
        tier: 'T2',
        photoUrl: null,
        bio: 'Hi',
        location: 'NYC',
        createdAt: DateTime(2026, 1, 1),
      );
      await repo.upsertUser(appUser);
      final snap = await firestore.collection('users').doc('u1').get();
      expect(snap.data()!['displayName'], 'Bob');
      expect(snap.data()!['bio'], 'Hi');
    });

    test('upsertUserProfile seeds defaults for new user', () async {
      await repo.upsertUserProfile(uid: 'new1', displayName: 'New');
      final snap = await firestore.collection('users').doc('new1').get();
      expect(snap.data()!['displayName'], 'New');
      expect(snap.data()!['xpTotal'], 0);
      expect(snap.data()!['streakCount'], 0);
    });

    test('updateProfile writes email to private doc', () async {
      await repo.updateProfile(
        uid: 'u1',
        displayName: 'Eve',
        email: 'eve@example.com',
      );
      final priv = await firestore
          .collection('users')
          .doc('u1')
          .collection('private')
          .doc('info')
          .get();
      expect(priv.data()!['email'], 'eve@example.com');
    });

    test('watchLeaderboard maps ordered users', () async {
      await firestore.collection('users').doc('a').set({
        'displayName': 'A',
        'xpTotal': 100,
      });
      await firestore.collection('users').doc('b').set({
        'displayName': 'B',
        'xpTotal': 200,
      });
      expect(
        repo.watchLeaderboard(limit: 10),
        emits(
          isA<List<AppUser>>()
              .having((l) => l.length, 'length', 2)
              .having((l) => l.first.xpTotal >= l.last.xpTotal, 'xp order', true),
        ),
      );
    });

    test('watchUser emits mapped user', () async {
      await firestore.collection('users').doc('u1').set({
        'displayName': 'Watcher',
        'xpTotal': 3,
      });
      expect(
        repo.watchUser('u1'),
        emits(
          isA<AppUser>().having((u) => u.displayName, 'name', 'Watcher'),
        ),
      );
    });
  });

  group('FirestoreJournalEntriesRepository', () {
    late FirestoreJournalEntriesRepository repo;

    setUp(() {
      repo = FirestoreJournalEntriesRepository(firestore, auth);
    });

    test('throws when not signed in', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect(() => repo.watchEntries(), throwsStateError);
    });

    test('createEntry writes under users/{uid}/entries', () async {
      final id = await repo.createEntry(
        mode: JournalEntryMode.text,
        promptText: 'P',
        bodyText: 'B',
      );
      expect(id, isNotEmpty);
      final doc = await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc(id)
          .get();
      expect(doc.exists, true);
      expect(doc.data()!['bodyText'], 'B');
    });

    test('updateEntryEvaluation and updateEntryBody', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e1')
          .set({
            'mode': 'text',
            'promptText': 'p',
            'bodyText': 'old',
            'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
            'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
          });
      await repo.updateEntryEvaluation(
        entryId: 'e1',
        energyIndex: 1,
        moodIndex: 2,
        internalIndex: 3,
      );
      await repo.updateEntryBody(entryId: 'e1', bodyText: 'new');
      final d = await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e1')
          .get();
      expect(d.data()!['energyIndex'], 1);
      expect(d.data()!['bodyText'], 'new');
    });

    test('updateEntryAudio transcript insight status delete restore', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e2')
          .set({
            'mode': 'voice',
            'promptText': 'p',
            'bodyText': 'b',
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
            'status': 'draft',
          });
      await repo.updateEntryAudio(entryId: 'e2', audioUrl: 'https://a');
      await repo.updateEntryTranscript(entryId: 'e2', transcript: 't');
      await repo.saveInsight(entryId: 'e2', insight: 'i');
      await repo.updateEntryStatus(entryId: 'e2', status: EntryStatus.uploading);
      var snap = await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e2')
          .get();
      expect(snap.data()!['status'], 'uploading');

      final entry = JournalEntry.fromMap(
        uid: 'u1',
        id: 'e2',
        data: snap.data(),
      );
      await repo.deleteEntry('e2');
      expect(
        (await firestore
                .collection('users')
                .doc('u1')
                .collection('entries')
                .doc('e2')
                .get())
            .exists,
        false,
      );
      await repo.restoreEntry(entry);
      expect(
        (await firestore
                .collection('users')
                .doc('u1')
                .collection('entries')
                .doc('e2')
                .get())
            .exists,
        true,
      );
    });

    test('restoreEntry rejects wrong uid', () async {
      final entry = JournalEntry(
        id: 'x',
        uid: 'other',
        mode: JournalEntryMode.text,
        promptText: 'p',
        bodyText: 'b',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        energyIndex: null,
        moodIndex: null,
        internalIndex: null,
      );
      expect(() => repo.restoreEntry(entry), throwsStateError);
    });

    test('watchEntries emits mapped list', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e1')
          .set({
            'mode': 'text',
            'promptText': 'p',
            'bodyText': 'hello',
            'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
            'updatedAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
          });
      expect(
        repo.watchEntries(),
        emits(isA<List<JournalEntry>>().having((l) => l.first.bodyText, 'body', 'hello')),
      );
    });

    test('watchEntry emits mapped entry', () async {
      await firestore
          .collection('users')
          .doc('u1')
          .collection('entries')
          .doc('e1')
          .set({
            'mode': 'text',
            'promptText': 'p',
            'bodyText': 'single',
            'createdAt': Timestamp.fromDate(DateTime(2026, 6, 2)),
            'updatedAt': Timestamp.fromDate(DateTime(2026, 6, 2)),
          });
      expect(
        repo.watchEntry('e1'),
        emits(
          isA<JournalEntry>().having((e) => e.bodyText, 'body', 'single'),
        ),
      );
    });
  });

  group('FirestoreLeaderboardRepository', () {
    test('fetchPage and cursor', () async {
      final repo = FirestoreLeaderboardRepository(firestore);
      for (var i = 0; i < 3; i++) {
        final id = 'id$i';
        await firestore.collection('users').doc(id).set({
          'uid': id,
          'displayName': 'U$i',
          'xpTotal': (3 - i) * 10,
        });
      }
      final first = await repo.fetchPage(limit: 2);
      expect(first.users.length, 2);
      expect(first.nextCursor, isNotNull);
      final second = await repo.fetchPage(
        limit: 2,
        cursor: first.nextCursor,
      );
      expect(second.users.isNotEmpty, true);
    });

    test('fetchPage empty collection', () async {
      final repo = FirestoreLeaderboardRepository(FakeFirebaseFirestore());
      final page = await repo.fetchPage(limit: 5);
      expect(page.users, isEmpty);
      expect(page.nextCursor, isNull);
    });
  });

  group('FirestorePromptsRepository', () {
    test('getLatestActive null when empty', () async {
      final repo = FirestorePromptsRepository(firestore);
      expect(await repo.getLatestActive(), isNull);
    });

    test('getLatestActive returns newest active prompt', () async {
      final repo = FirestorePromptsRepository(firestore);
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 2, 1);
      await firestore.collection('prompts').doc('p1').set({
        'text': 'Old',
        'date': Timestamp.fromDate(older),
        'active': true,
      });
      await firestore.collection('prompts').doc('p2').set({
        'text': 'New',
        'date': Timestamp.fromDate(newer),
        'active': true,
      });
      final p = await repo.getLatestActive();
      expect(p, isNotNull);
      expect(p!.id, 'p2');
      expect(p.text, 'New');
    });

    test('watchLatestActive emits newest active prompt', () async {
      final repo = FirestorePromptsRepository(firestore);
      await firestore.collection('prompts').doc('p1').set({
        'text': 'Stream',
        'date': Timestamp.fromDate(DateTime(2026, 4, 1)),
        'active': true,
      });
      expect(
        repo.watchLatestActive(),
        emits(isA<Prompt>().having((p) => p.text, 'text', 'Stream')),
      );
    });
  });
}
