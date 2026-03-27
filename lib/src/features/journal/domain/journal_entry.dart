import 'package:cloud_firestore/cloud_firestore.dart';

enum JournalEntryMode { text, voice }

/// Upload / processing status for voice entries.
enum EntryStatus {
  /// Text entry or initial draft.
  draft,
  /// Audio is being uploaded to Storage.
  uploading,
  /// Audio has been uploaded; waiting for transcription.
  uploaded,
  /// Cloud Function is running speech-to-text.
  transcribing,
  /// Transcript is ready; AI insights may still be pending.
  transcribed,
  /// AI insights have been generated and saved.
  done,
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
    this.audioUrl,
    this.transcript,
    this.aiInsight,
    this.status = EntryStatus.draft,
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

  /// Download URL for the voice recording (voice entries only).
  final String? audioUrl;

  /// Transcript produced by the transcription pipeline.
  final String? transcript;

  /// AI-generated insight text (populated after generateInsights runs).
  final String? aiInsight;

  /// Current processing status for voice / AI pipeline.
  final EntryStatus status;

  static JournalEntryMode _parseMode(Object? value) {
    final raw = value?.toString();
    return raw == 'voice' ? JournalEntryMode.voice : JournalEntryMode.text;
  }

  static EntryStatus _parseStatus(Object? value) {
    switch (value?.toString()) {
      case 'uploading':
        return EntryStatus.uploading;
      case 'uploaded':
        return EntryStatus.uploaded;
      case 'transcribing':
        return EntryStatus.transcribing;
      case 'transcribed':
        return EntryStatus.transcribed;
      case 'done':
        return EntryStatus.done;
      default:
        return EntryStatus.draft;
    }
  }

  static String _statusToString(EntryStatus s) {
    switch (s) {
      case EntryStatus.uploading:
        return 'uploading';
      case EntryStatus.uploaded:
        return 'uploaded';
      case EntryStatus.transcribing:
        return 'transcribing';
      case EntryStatus.transcribed:
        return 'transcribed';
      case EntryStatus.done:
        return 'done';
      case EntryStatus.draft:
        return 'draft';
    }
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
      audioUrl: data['audioUrl'] as String?,
      transcript: data['transcript'] as String?,
      aiInsight: data['aiInsight'] as String?,
      status: _parseStatus(data['status']),
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
      'status': _statusToString(status),
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (transcript != null) 'transcript': transcript,
      if (aiInsight != null) 'aiInsight': aiInsight,
    };
  }

  JournalEntry copyWith({
    String? audioUrl,
    String? transcript,
    String? aiInsight,
    EntryStatus? status,
    String? bodyText,
  }) {
    return JournalEntry(
      id: id,
      uid: uid,
      mode: mode,
      promptText: promptText,
      bodyText: bodyText ?? this.bodyText,
      createdAt: createdAt,
      updatedAt: updatedAt,
      energyIndex: energyIndex,
      moodIndex: moodIndex,
      internalIndex: internalIndex,
      audioUrl: audioUrl ?? this.audioUrl,
      transcript: transcript ?? this.transcript,
      aiInsight: aiInsight ?? this.aiInsight,
      status: status ?? this.status,
    );
  }
}

