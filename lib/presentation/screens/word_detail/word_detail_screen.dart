import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../domain/entities/word_entry.dart';
import '../../providers/dictionary_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/definition_card.dart';
import 'widgets/translation_section.dart';
import 'widgets/examples_section.dart';

class WordDetailScreen extends ConsumerStatefulWidget {
  final int wordId;

  const WordDetailScreen({
    super.key,
    required this.wordId,
  });

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Add to history when viewing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).addToHistory(widget.wordId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordAsync = ref.watch(wordByIdProvider(widget.wordId));
    final isFavoriteAsync = ref.watch(watchIsFavoriteProvider(widget.wordId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Favorite button
          isFavoriteAsync.when(
            data: (isFavorite) => IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.error : null,
              ),
              onPressed: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(widget.wordId);
              },
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
            loading: () => const IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: null,
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
            tooltip: 'Share',
          ),
        ],
      ),
      body: wordAsync.when(
        data: (word) {
          if (word == null) {
            return const Center(
              child: Text('Word not found'),
            );
          }
          return _WordDetailContent(word: word);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading word: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordDetailContent extends ConsumerWidget {
  final WordEntry word;

  const _WordDetailContent({required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetLanguage = ref.watch(targetLanguageProvider);
    final isHindi = word.isHindi;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word header
          _WordHeader(word: word),
          const SizedBox(height: 24),

          // Translations
          if (word.hasTranslationsTo(targetLanguage.code)) ...[
            TranslationSection(
              translations: word.getTranslations(targetLanguage.code),
              targetLanguage: targetLanguage,
            ),
            const SizedBox(height: 24),
          ],

          // Definitions
          if (word.definitions.isNotEmpty) ...[
            DefinitionCard(
              definitions: word.definitions,
              pos: word.pos,
            ),
            const SizedBox(height: 24),
          ],

          // Examples
          if (word.examples.isNotEmpty) ...[
            ExamplesSection(examples: word.examples),
            const SizedBox(height: 24),
          ],

          // Etymology
          if (word.etymology != null && word.etymology!.isNotEmpty) ...[
            _EtymologySection(etymology: word.etymology!),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  final WordEntry word;

  const _WordHeader({required this.word});

  @override
  Widget build(BuildContext context) {
    final isHindi = word.isHindi;
    final badgeColor = isHindi ? AppColors.hindiBadge : AppColors.englishBadge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            word.languageCode == 'en' ? 'English' : 'Hindi',
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Word
        Text(
          word.word,
          style: isHindi ? AppTypography.hindiTitle : AppTypography.wordTitle,
        ),

        // Pronunciation
        if (word.pronunciationIpa != null) ...[
          const SizedBox(height: 4),
          Text(
            '/${word.pronunciationIpa}/',
            style: AppTypography.pronunciationText,
          ),
        ],

        // Part of speech
        if (word.pos != null) ...[
          const SizedBox(height: 8),
          _PosChip(pos: word.formattedPos),
        ],
      ],
    );
  }
}

class _PosChip extends StatelessWidget {
  final String pos;

  const _PosChip({required this.pos});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getPosColor(pos);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        pos,
        style: AppTypography.posLabel.copyWith(color: color),
      ),
    );
  }
}

class _EtymologySection extends StatelessWidget {
  final String etymology;

  const _EtymologySection({required this.etymology});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etymology',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              etymology,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
