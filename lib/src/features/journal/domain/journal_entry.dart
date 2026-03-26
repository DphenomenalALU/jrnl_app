import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalEntryMode {
  text,
  voice,
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.uid,
    required this.mode,
    required this.promptText,
    required this.bodyText,
    required this.createdAt,
    required this.updatedAt,
    required this.energyIndex,
    required this.moodIndex,
    required this.internalIndex,
  });

  final String id;
  final String uid;
  final JournalEntryMode mode;
  final String promptText;
  final String bodyText;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 0–4 (nullable until user completes evaluation).
  final int? energyIndex;
  final int? moodIndex;
  final int? internalIndex;

  static JournalEntryMode _parseMode(Object? value) {
    final raw = value?.toString();
    return raw == 'voice' ? JournalEntryMode.voice : JournalEntryMode.text;
  }

  static JournalEntry fromDoc({
    required String uid,
    required DocumentSnapshot<Map<String, dynamic>> doc,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    return JournalEntry(
      id: doc.id,
      uid: uid,
      mode: _parseMode(data['mode']),
      promptText: (data['promptText'] as String?) ?? '',
      bodyText: (data['bodyText'] as String?) ?? '',
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? createdAt ?? now,
      energyIndex: data['energyIndex'] as int?,
      moodIndex: data['moodIndex'] as int?,
      internalIndex: data['internalIndex'] as int?,
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'mode': mode == JournalEntryMode.voice ? 'voice' : 'text',
      'promptText': promptText,
      'bodyText': bodyText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'energyIndex': energyIndex,
      'moodIndex': moodIndex,
      'internalIndex': internalIndex,
    };
  }
}

