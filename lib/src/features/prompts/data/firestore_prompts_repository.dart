import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/prompt.dart';
import '../domain/prompts_repository.dart';

class FirestorePromptsRepository implements PromptsRepository {
  FirestorePromptsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _prompts =>
      _firestore.collection('prompts');

  Query<Map<String, dynamic>> get _latestActiveQuery => _prompts
      .where('active', isEqualTo: true)
      .orderBy('date', descending: true)
      .limit(1);

  @override
  Stream<Prompt?> watchLatestActive() {
    return _latestActiveQuery.snapshots().map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return Prompt.fromJson(<String, dynamic>{...doc.data(), 'id': doc.id});
    });
  }

  @override
  Future<Prompt?> getLatestActive() async {
    final snap = await _latestActiveQuery.get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Prompt.fromJson(<String, dynamic>{...doc.data(), 'id': doc.id});
  }
}
