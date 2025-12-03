import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../providers/settings_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/dictionary_providers.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/recent_searches_widget.dart';
import 'widgets/language_toggle_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              title: const Text('Dictionary'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_outline),
                  onPressed: () => context.push('/favorites'),
                  tooltip: 'Favorites',
                ),
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () => context.push('/history'),
                  tooltip: 'History',
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/settings'),
                  tooltip: 'Settings',
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Language toggle
                  const LanguageToggleWidget(),
                  const SizedBox(height: 24),

                  // Search bar
                  SearchBarWidget(
                    onTap: () => context.push('/search'),
                    readOnly: true,
                    hintText: 'Search for a word...',
                  ),
                  const SizedBox(height: 32),

                  // Recent searches
                  const RecentSearchesWidget(),
                  const SizedBox(height: 24),

                  // Database stats
                  const _DatabaseStatsCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatabaseStatsCard extends ConsumerWidget {
  const _DatabaseStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(databaseStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats.totalWordCount == 0) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Database Empty',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Run the data processing scripts to populate the dictionary database.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dictionary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: 'English',
                        value: _formatNumber(stats.englishWordCount),
                        color: AppColors.englishBadge,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Hindi',
                        value: _formatNumber(stats.hindiWordCount),
                        color: AppColors.hindiBadge,
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'Total',
                        value: _formatNumber(stats.totalWordCount),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (stats.version != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Version: ${stats.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading stats: $error'),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
