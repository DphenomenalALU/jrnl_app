import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/journal_entry.dart';
import '../domain/journal_entries_repository.dart';

class FirestoreJournalEntriesRepository implements JournalEntriesRepository {
  FirestoreJournalEntriesRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not signed in.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> _entriesRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('entries');
  }

  @override
  Stream<List<JournalEntry>> watchEntries() {
    final uid = _uid;
    return _entriesRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) => JournalEntry.fromDoc(uid: uid, doc: d)).toList();
    });
  }

  @override
  Stream<JournalEntry?> watchEntry(String entryId) {
    final uid = _uid;
    return _entriesRef(uid).doc(entryId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return JournalEntry.fromDoc(uid: uid, doc: doc);
    });
  }

  @override
  Future<String> createEntry({
    required JournalEntryMode mode,
    required String promptText,
    required String bodyText,
  }) async {
    final uid = _uid;
    final now = DateTime.now();
    final doc = _entriesRef(uid).doc();
    final entry = JournalEntry(
      id: doc.id,
      uid: uid,
      mode: mode,
      promptText: promptText,
      bodyText: bodyText,
      createdAt: now,
      updatedAt: now,
      energyIndex: null,
      moodIndex: null,
      internalIndex: null,
    );
    await doc.set(entry.toFirestore());
    return doc.id;
  }

  @override
  Future<void> updateEntryEvaluation({
    required String entryId,
    required int energyIndex,
    required int moodIndex,
    required int internalIndex,
  }) async {
    final uid = _uid;
    await _entriesRef(uid).doc(entryId).update({
      'energyIndex': energyIndex,
      'moodIndex': moodIndex,
      'internalIndex': internalIndex,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> updateEntryBody({
    required String entryId,
    required String bodyText,
  }) async {
    final uid = _uid;
    await _entriesRef(uid).doc(entryId).update({
      'bodyText': bodyText,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    final uid = _uid;
    await _entriesRef(uid).doc(entryId).delete();
  }

  @override
  Future<void> restoreEntry(JournalEntry entry) async {
    final uid = _uid;
    if (entry.uid != uid) {
      throw StateError('Cannot restore entry for a different user.');
    }
    await _entriesRef(uid).doc(entry.id).set(entry.toFirestore());
  }
}

