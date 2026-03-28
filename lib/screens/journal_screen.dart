import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
import '../src/core/di/providers.dart';
import '../src/features/journal/domain/journal_entries_repository.dart';
import '../src/features/journal/domain/journal_entry.dart';
import '../src/core/services/app_prefs.dart';
import '../src/features/journal/presentation/journal_providers.dart';
import '../src/features/prompts/presentation/latest_prompt_provider.dart';
import '../src/features/users/presentation/current_app_user_provider.dart';
import 'ai_insights_screen.dart';
import 'entry_summary_screen.dart';

/// Matches waveform track + pill vertical padding in [_VoiceJournalCard].
const double _kWaveformTrackHeight = 15;
const double _kVoicePillVerticalPadding = 8;

/// Total height of the recording pill (padding + waveform row).
const double _kVoicePillHeight =
    _kWaveformTrackHeight + 2 * _kVoicePillVerticalPadding;

/// Mic beside the pill: scaled to pill height (slightly smaller than the pill).
const double _kVoiceMicIconSize = 0.72 * _kVoicePillHeight;

/// Journal entry: text mode (default) and voice recording mode.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key, this.onPostEntryComplete});

  /// After Entry Summary → Consistency → CONTINUE, shell switches to Leaderboard.
  final VoidCallback? onPostEntryComplete;

  /// Mock streak day shown in the header (wire to real data later).
  static const int fallbackStreakDay = 0;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _body = TextEditingController();
  late final AnimationController _waveCtrl;
  final AudioRecorder _recorder = AudioRecorder();

  bool _voiceMode = false;
  bool _isRecording = false;
  bool _showAiInsights = false;
  bool _saving = false;
  String? _recordedFilePath;
  String? _currentEntryId;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recorder.dispose();
    _waveCtrl.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _setVoiceMode(bool enabled) async {
    setState(() => _voiceMode = enabled);
    if (enabled) {
      _waveCtrl.repeat(reverse: true);
      await _startRecording();
    } else {
      _waveCtrl.stop();
      _waveCtrl.reset();
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied.')),
        );
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/jrnl_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _isRecording = true;
      _recordedFilePath = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    await _recorder.stop();
    setState(() => _isRecording = false);
  }

  Future<void> _onDone() async {
    if (_saving) return;

    if (_voiceMode && _isRecording) {
      await _stopRecording();
    }
    if (!mounted) return;

    final bodyText = _voiceMode ? '' : _body.text.trim();
    if (!_voiceMode && bodyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first.')),
      );
      return;
    }

    setState(() => _saving = true);

    final promptText = ref.read(latestPromptProvider).valueOrNull?.text ??
        'What did you leave unsaid today?';
    final repo = ref.read(journalEntriesRepositoryProvider);
    final uid = ref.read(currentUidProvider);

    String entryId;
    try {
      entryId = await repo.createEntry(
        mode: _voiceMode ? JournalEntryMode.voice : JournalEntryMode.text,
        promptText: promptText,
        bodyText: bodyText,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
      setState(() => _saving = false);
      return;
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      _currentEntryId = entryId;
    });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Entry saved')));

    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (navCtx) => EntrySummaryScreen(
          entryId: entryId,
          onContinueToLeaderboard: widget.onPostEntryComplete,
        ),
      ),
    );

    // Kick off the voice pipeline in the background; UI listens to the entry
    // document's status field for progress.
    if (_voiceMode && _recordedFilePath != null && uid != null) {
      // Ignore: this runs after navigation; failures surface as snackbars if possible.
      // We intentionally do not block the UI on uploads/transcription.
      // ignore: unawaited_futures
      _uploadAndMaybeTranscribe(
        repo: repo,
        uid: uid,
        entryId: entryId,
        recordedFilePath: _recordedFilePath!,
      );
    }
  }

  Future<void> _uploadAndMaybeTranscribe({
    required JournalEntriesRepository repo,
    required String uid,
    required String entryId,
    required String recordedFilePath,
  }) async {
    try {
      await repo.updateEntryStatus(
        entryId: entryId,
        status: EntryStatus.uploading,
      );
      final storageRef = ref
          .read(firebaseStorageProvider)
          .ref()
          .child('voices/$uid/$entryId.m4a');
      final snapshot = await storageRef.putFile(File(recordedFilePath));
      final downloadUrl = await snapshot.ref.getDownloadURL();
      await repo.updateEntryAudio(
        entryId: entryId,
        audioUrl: downloadUrl,
      );

      final autoTranscribe = ref.read(voiceAutoTranscribeProvider);
      if (!autoTranscribe) return;

      try {
        final callable =
            FirebaseFunctions.instance.httpsCallable('transcribeVoiceEntry');
        await callable.call({'entryId': entryId});
      } catch (_) {
        // Non-fatal — transcription can be triggered manually in AI Insights.
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio upload failed: $e')),
      );
    }
  }

  void _onExploreDeeply() {
    setState(() => _showAiInsights = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showAiInsights) {
      return AiInsightsScreen(
        onBack: () => setState(() => _showAiInsights = false),
        entryId: _currentEntryId,
      );
    }

    final streakDay =
        ref.watch(currentAppUserProvider).valueOrNull?.streakCount ??
            JournalScreen.fallbackStreakDay;
    final promptText = ref.watch(latestPromptProvider).valueOrNull?.text ??
        'What did you leave unsaid today?';
    final currentEntryId = _currentEntryId;
    final currentEntry = currentEntryId == null
        ? null
        : ref.watch(journalEntryProvider(currentEntryId)).valueOrNull;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              _JournalHeader(
                day: streakDay,
                onOpenHistory: () => context.push('/journal/history'),
              ),
              const SizedBox(height: 28),
              _JournalPrompt(promptText: promptText),
              const SizedBox(height: 24),
              Expanded(
                child: _voiceMode
                    ? _VoiceJournalCard(
                        controller: _waveCtrl,
                        isRecording: _isRecording,
                        onExitVoice: () => _setVoiceMode(false),
                      )
                    : _TextJournalSection(
                        controller: _body,
                        onMic: () => _setVoiceMode(true),
                      ),
              ),
              const SizedBox(height: 8),
              if (currentEntry != null &&
                  currentEntry.mode == JournalEntryMode.voice) ...[
                _VoicePipelineStatusLine(status: currentEntry.status),
                const SizedBox(height: 8),
              ],
              _OutlineCta(
                label: 'EXPLORE DEEPLY',
                onPressed: _onExploreDeeply,
              ),
              const SizedBox(height: 10),
              _FilledCta(
                label: 'DONE',
                onPressed: _saving ? null : _onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.day, required this.onOpenHistory});

  final int day;
  final VoidCallback onOpenHistory;

  static const double _sideSlot = 96;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _sideSlot,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'lib/assets/journal_icons/sparkle.svg',
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: _sideSlot,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _HistoryChip(onTap: onOpenHistory),
                ),
              ),
            ],
          ),
          IgnorePointer(
            child: Text(
              'DAY $day',
              style: AppTextStyles.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: AppColors.labelTertiary,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Text(
            'HISTORY',
            style: AppTextStyles.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalPrompt extends StatelessWidget {
  const _JournalPrompt({required this.promptText});

  final String promptText;

  @override
  Widget build(BuildContext context) {
    return Text(
      promptText,
      style: AppTextStyles.playfair(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        height: 1.2,
        color: AppColors.primary,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

/// Gray input block fills available height; image/mic sit below the field, outside the card.
class _TextJournalSection extends StatelessWidget {
  const _TextJournalSection({
    required this.controller,
    required this.onMic,
  });

  final TextEditingController controller;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inputSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              keyboardType: TextInputType.multiline,
              style: AppTextStyles.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.labelSecondary,
                height: 1.5,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Write anything here...',
                hintStyle: AppTextStyles.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelTertiary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: SvgPicture.asset(
                'lib/assets/journal_icons/image-upload.svg',
                width: 20,
                height: 18,
                fit: BoxFit.contain,
              ),
              tooltip: 'Add image',
            ),
            const Spacer(),
            IconButton(
              onPressed: onMic,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: SvgPicture.asset(
                'lib/assets/journal_icons/mic.svg',
                width: 16,
                height: 20,
                fit: BoxFit.contain,
              ),
              tooltip: 'Voice mode',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.journalToolbarLine),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _VoiceJournalCard extends StatelessWidget {
  const _VoiceJournalCard({
    required this.controller,
    required this.isRecording,
    required this.onExitVoice,
  });

  final AnimationController controller;
  final bool isRecording;
  final VoidCallback onExitVoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.inputSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            alignment: Alignment.topLeft,
            child: Text(
              isRecording ? 'Recording…' : 'Tap mic to start recording.',
              style: AppTextStyles.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: AppColors.labelTertiary,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: _kVoicePillVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.recordingTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.recordingRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          return _WaveformBars(t: controller.value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onExitVoice,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    'lib/assets/journal_icons/mic-voice.svg',
                    height: _kVoiceMicIconSize,
                    width: _kVoiceMicIconSize * 16 / 20,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.journalToolbarLine),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    const count = 52;
    return SizedBox(
      height: _kWaveformTrackHeight,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(count, (i) {
          final phase = t * 2 * math.pi + i * 0.28;
          final h = 2.5 + 7.5 * (0.5 + 0.5 * math.sin(phase));
          return Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 1.75,
                height: h.clamp(2.0, 12.0),
                decoration: BoxDecoration(
                  color: AppColors.recordingRed,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OutlineCta extends StatelessWidget {
  const _OutlineCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1),
        backgroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.6,
          color: AppColors.primary,
          height: 1,
        ),
      ),
    );
  }
}

class _FilledCta extends StatelessWidget {
  const _FilledCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.6,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}

class _VoicePipelineStatusLine extends StatelessWidget {
  const _VoicePipelineStatusLine({required this.status});

  final EntryStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      EntryStatus.uploading => 'Uploading voice entry…',
      EntryStatus.uploaded => 'Uploaded. Ready to transcribe.',
      EntryStatus.transcribing => 'Transcribing…',
      EntryStatus.transcribed => 'Transcribed. Ready for insights.',
      EntryStatus.done => 'Insights ready.',
      EntryStatus.draft => 'Draft saved.',
    };

    return Text(
      label,
      textAlign: TextAlign.center,
      style: AppTextStyles.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.labelSecondary,
        height: 1.2,
      ),
    );
  }
}
