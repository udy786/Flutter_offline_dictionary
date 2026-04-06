import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/banner_ad_widget.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
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
                          'Favorites',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimaryC,
                          ),
                        ),
                        if (favoritesState.favorites.isNotEmpty)
                          Text(
                            '${favoritesState.favorites.length} words',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textSecondaryC,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (favoritesState.favorites.isNotEmpty)
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
              child: _buildBody(context, ref, favoritesState, theme),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: BannerAdWidget(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref,
      FavoritesState state, ThemeData theme) {
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
                    ref.read(favoritesProvider.notifier).loadFavorites(),
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
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_outline_rounded,
                    size: 44, color: Colors.red.shade200),
              ),
              const SizedBox(height: 20),
              Text(
                'No favorites yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the heart icon on any word to save it here',
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

    return ListView.separated(
      itemCount: state.favorites.length,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = state.favorites[index];
        final word = entry.word;
        final isHindi = word.isHindi;
        final color =
            isHindi ? const Color(0xFFFF9800) : const Color(0xFF2196F3);

        return Dismissible(
          key: Key('favorite_${entry.id}'),
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
          onDismissed: (_) {
            ref.read(favoritesProvider.notifier).removeFromFavorites(word.id);
          },
          child: GestureDetector(
            onTap: () => context.push('/word/${word.id}'),
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
                            fontFamily:
                                isHindi ? 'NotoSansDevanagari' : null,
                          ),
                        ),
                        if (word.primaryDefinition != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            word.primaryDefinition!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textSecondaryC,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Favorite icon
                  GestureDetector(
                    onTap: () => ref
                        .read(favoritesProvider.notifier)
                        .removeFromFavorites(word.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.favorite_rounded,
                          color: Colors.red.shade400, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear favorites?'),
        content: const Text(
            'This will remove all words from your favorites. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesProvider.notifier).clearFavorites();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
