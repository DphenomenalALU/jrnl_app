import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/core/presentation/theme/app_colors.dart';
import '../src/core/presentation/theme/app_text_styles.dart';
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
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key, this.onPostEntryComplete});

  /// After Entry Summary → Consistency → CONTINUE, shell switches to Leaderboard.
  final VoidCallback? onPostEntryComplete;

  /// Mock streak day shown in the header (wire to real data later).
  static const int streakDay = 15;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _body = TextEditingController();
  late final AnimationController _waveCtrl;

  bool _voiceMode = false;
  bool _showAiInsights = false;

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
    _waveCtrl.dispose();
    _body.dispose();
    super.dispose();
  }

  void _setVoiceMode(bool enabled) {
    setState(() => _voiceMode = enabled);
    if (enabled) {
      _waveCtrl.repeat(reverse: true);
    } else {
      _waveCtrl.stop();
      _waveCtrl.reset();
    }
  }

  void _onDone() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (navCtx) => EntrySummaryScreen(
          onContinueToLeaderboard: widget.onPostEntryComplete,
        ),
      ),
    );
  }

  void _onExploreDeeply() {
    setState(() => _showAiInsights = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_showAiInsights) {
      return AiInsightsScreen(
        onBack: () => setState(() => _showAiInsights = false),
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _JournalHeader(day: JournalScreen.streakDay),
              const SizedBox(height: 28),
              const _JournalPrompt(),
              const SizedBox(height: 24),
              Expanded(
                child: _voiceMode
                    ? _VoiceJournalCard(
                        controller: _waveCtrl,
                        onExitVoice: () => _setVoiceMode(false),
                      )
                    : _TextJournalSection(
                        controller: _body,
                        onMic: () => _setVoiceMode(true),
                      ),
              ),
              const SizedBox(height: 8),
              _OutlineCta(
                label: 'EXPLORE DEEPLY',
                onPressed: _onExploreDeeply,
              ),
              const SizedBox(height: 10),
              _FilledCta(
                label: 'DONE',
                onPressed: _onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalHeader extends StatelessWidget {
  const _JournalHeader({required this.day});

  final int day;

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
                  child: _HistoryChip(),
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
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {},
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
  const _JournalPrompt();

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.playfair(
      fontSize: 40,
      fontWeight: FontWeight.w400,
      height: 1.2,
      color: AppColors.primary,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'What did you leave '),
          TextSpan(
            text: 'unsaid',
            style: base.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const TextSpan(text: ' today?'),
        ],
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
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
    required this.onExitVoice,
  });

  final AnimationController controller;
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
              'Recording...',
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
  final VoidCallback onPressed;

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
