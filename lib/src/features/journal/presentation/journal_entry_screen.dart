import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';
import '../domain/journal_entry.dart';
import 'journal_providers.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final TextEditingController _body = TextEditingController();
  bool _didInitText = false;
  bool _saving = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _save(JournalEntry entry) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(journalEntriesRepositoryProvider)
          .updateEntryBody(entryId: entry.id, bodyText: _body.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Saved')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(JournalEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone from the detail screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref.read(journalEntriesRepositoryProvider).deleteEntry(entry.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(journalEntryProvider(widget.entryId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: entryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Failed to load entry.\n$e',
                textAlign: TextAlign.center,
                style: AppTextStyles.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.labelSecondary,
                ),
              ),
            ),
          ),
          data: (entry) {
            if (entry == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Entry not found.',
                    style: AppTextStyles.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelSecondary,
                    ),
                  ),
                ),
              );
            }

            if (!_didInitText) {
              _didInitText = true;
              _body.text = entry.bodyText;
            }

            final date = DateFormat(
              'MMM d, y • h:mm a',
            ).format(entry.createdAt);
            final eval =
                (entry.energyIndex != null &&
                    entry.moodIndex != null &&
                    entry.internalIndex != null)
                ? 'Energy ${entry.energyIndex}, Mood ${entry.moodIndex}, Internal ${entry.internalIndex}'
                : 'Not evaluated yet';

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Back',
                      ),
                      Expanded(
                        child: Text(
                          'Entry',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.playfair(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _delete(entry),
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.labelSecondary,
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date,
                    style: AppTextStyles.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: AppColors.labelTertiary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.promptText.isEmpty
                        ? 'Journal entry'
                        : entry.promptText,
                    style: AppTextStyles.playfair(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Body',
                    style: AppTextStyles.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: TextField(
                        controller: _body,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        keyboardType: TextInputType.multiline,
                        style: AppTextStyles.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.labelSecondary,
                          height: 1.5,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write anything here...',
                          hintStyle: AppTextStyles.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.labelTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Evaluation',
                    style: AppTextStyles.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    eval,
                    style: AppTextStyles.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.labelSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : () => _save(entry),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _saving ? 'SAVING...' : 'SAVE CHANGES',
                      style: AppTextStyles.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
