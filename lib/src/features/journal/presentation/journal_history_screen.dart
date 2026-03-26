import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/theme/app_colors.dart';
import '../../../core/presentation/theme/app_text_styles.dart';
import '../domain/journal_entry.dart';
import 'journal_providers.dart';

final _hiddenEntryIdsProvider = StateProvider.autoDispose<Set<String>>((ref) {
  return <String>{};
});

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final hiddenIds = ref.watch(_hiddenEntryIdsProvider);

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                    tooltip: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      'History',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.playfair(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: entriesAsync.when(
                  data: (entries) {
                    final visible = entries.where((e) => !hiddenIds.contains(e.id)).toList();
                    if (visible.isEmpty) {
                      return Center(
                        child: Text(
                          'No entries yet.',
                          style: AppTextStyles.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.labelSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final entry = visible[index];
                        return _EntryTile(
                          entry: entry,
                          onOpen: () => context.push('/journal/entry/${entry.id}'),
                          onDelete: () => _deleteEntry(context, ref, entry),
                        );
                      },
                    );
                  },
                  error: (e, _) {
                    return Center(
                      child: Text(
                        'Failed to load entries.\n$e',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.labelSecondary,
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    ref.read(_hiddenEntryIdsProvider.notifier).update((s) => {...s, entry.id});

    try {
      await ref.read(journalEntriesRepositoryProvider).deleteEntry(entry.id);
    } catch (e) {
      ref.read(_hiddenEntryIdsProvider.notifier).update((s) {
        final next = {...s}..remove(entry.id);
        return next;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Entry deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              try {
                await ref.read(journalEntriesRepositoryProvider).restoreEntry(entry);
                ref.read(_hiddenEntryIdsProvider.notifier).update((s) {
                  final next = {...s}..remove(entry.id);
                  return next;
                });
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Undo failed: $e')),
                );
              }
            },
          ),
        ),
      );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.onOpen,
    required this.onDelete,
  });

  final JournalEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d • h:mm a').format(entry.createdAt);
    final hasEval = entry.energyIndex != null &&
        entry.moodIndex != null &&
        entry.internalIndex != null;

    return Material(
      color: AppColors.inputSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: AppTextStyles.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: AppColors.labelTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.promptText.isEmpty ? 'Journal entry' : entry.promptText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.playfair(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                        height: 1.25,
                      ),
                    ),
                    if (entry.bodyText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        entry.bodyText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.labelSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Pill(
                          label: entry.mode == JournalEntryMode.voice ? 'VOICE' : 'TEXT',
                        ),
                        const SizedBox(width: 8),
                        _Pill(label: hasEval ? 'EVALUATED' : 'UNEVALUATED'),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.labelSecondary,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.labelSecondary,
          height: 1,
        ),
      ),
    );
  }
}
