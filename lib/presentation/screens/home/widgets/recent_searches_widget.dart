import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/colors.dart';
import '../../../providers/history_provider.dart';

class RecentSearchesWidget extends ConsumerWidget {
  const RecentSearchesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchesProvider);

    return recentAsync.when(
      data: (recent) {
        if (recent.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => context.push('/history'),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recent.take(8).map((word) {
                return ActionChip(
                  label: Text(word.word),
                  avatar: CircleAvatar(
                    backgroundColor: word.isEnglish
                        ? AppColors.englishBadge.withOpacity(0.2)
                        : AppColors.hindiBadge.withOpacity(0.2),
                    child: Text(
                      word.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: word.isEnglish
                            ? AppColors.englishBadge
                            : AppColors.hindiBadge,
                      ),
                    ),
                  ),
                  onPressed: () => context.push('/word/${word.id}'),
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
