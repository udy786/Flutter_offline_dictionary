import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../domain/repositories/user_data_repository.dart';
import '../../providers/history_provider.dart';
import '../../widgets/banner_ad_widget.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              decoration: BoxDecoration(
                color: context.headerBg,
                boxShadow: [
                  BoxShadow(
                    color: context.subtleShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.textPrimaryC,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryC,
                          ),
                        ),
                        if (historyState.history.isNotEmpty)
                          Text(
                            '${historyState.history.length} words',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textSecondaryC,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (historyState.history.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showClearDialog(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.dividerC,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            size: 20, color: context.textSecondaryC),
                      ),
                    ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _buildBody(context, ref, historyState, theme),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const SafeArea(
      //   child: BannerAdWidget(),
      // ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      HistoryState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2196F3)),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded,
                    size: 36, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              Text('Something went wrong',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(historyProvider.notifier).loadHistory(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history_rounded,
                    size: 44,
                    color: const Color(0xFF00BCD4).withOpacity(0.4)),
              ),
              const SizedBox(height: 20),
              Text(
                'No search history',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Words you look up will appear here',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group by date
    final grouped = _groupByDate(state.history);

    return ListView.builder(
      itemCount: grouped.length,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemBuilder: (context, index) {
        final group = grouped[index];
        return _HistoryGroup(
          dateLabel: group.dateLabel,
          entries: group.entries,
          onEntryTap: (entry) => context.push('/word/${entry.word.id}'),
          onEntryRemove: (entry) {
            ref
                .read(historyProvider.notifier)
                .removeFromHistory(entry.word.id);
          },
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<HistoryEntry>>{};

    for (final entry in entries) {
      final date = DateTime(
        entry.searchedAt.year,
        entry.searchedAt.month,
        entry.searchedAt.day,
      );

      String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${date.day}/${date.month}/${date.year}';
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(entry);
    }

    return groups.entries.map((e) => _DateGroup(e.key, e.value)).toList();
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear history?'),
        content: const Text(
            'This will remove all search history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            style:
                TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _DateGroup {
  final String dateLabel;
  final List<HistoryEntry> entries;

  _DateGroup(this.dateLabel, this.entries);
}

class _HistoryGroup extends StatelessWidget {
  final String dateLabel;
  final List<HistoryEntry> entries;
  final ValueChanged<HistoryEntry> onEntryTap;
  final ValueChanged<HistoryEntry> onEntryRemove;

  const _HistoryGroup({
    required this.dateLabel,
    required this.entries,
    required this.onEntryTap,
    required this.onEntryRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          child: Text(
            dateLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: context.textSecondaryC,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryItem(
                entry: entry,
                onTap: () => onEntryTap(entry),
                onRemove: () => onEntryRemove(entry),
              ),
            )),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryItem({
    required this.entry,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final word = entry.word;
    final isHindi = word.isHindi;
    final color =
        isHindi ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('history_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.dividerC),
            boxShadow: [
              BoxShadow(
                color: context.subtleShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Language badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  word.languageCode.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryC,
                        fontFamily: isHindi ? 'NotoSansDevanagari' : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(entry.searchedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
