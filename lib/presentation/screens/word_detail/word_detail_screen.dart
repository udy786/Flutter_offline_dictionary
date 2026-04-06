import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).addToHistory(widget.wordId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wordAsync = ref.watch(wordByIdProvider(widget.wordId));
    final isFavoriteAsync = ref.watch(watchIsFavoriteProvider(widget.wordId));

    return Scaffold(
      backgroundColor: context.screenBg,
      body: wordAsync.when(
        data: (word) {
          if (word == null) {
            return const Center(child: Text('Word not found'));
          }
          return _WordDetailBody(
            word: word,
            isFavoriteAsync: isFavoriteAsync,
            wordId: widget.wordId,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
        error: (error, _) => SafeArea(
          child: Center(
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
                  Text('Error loading word',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('$error',
                      style: TextStyle(color: context.textSecondaryC),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordDetailBody extends ConsumerWidget {
  final WordEntry word;
  final AsyncValue<bool> isFavoriteAsync;
  final int wordId;

  const _WordDetailBody({
    required this.word,
    required this.isFavoriteAsync,
    required this.wordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetLanguage = ref.watch(targetLanguageProvider);
    final theme = Theme.of(context);
    final isHindi = word.isHindi;
    final accentColor =
        isHindi ? const Color(0xFFFF9800) : const Color(0xFF2196F3);

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor,
                  accentColor.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        Row(
                          children: [
                            // Favorite button
                            isFavoriteAsync.when(
                              data: (isFavorite) => GestureDetector(
                                onTap: () => ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(wordId),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_outline_rounded,
                                    color: isFavorite
                                        ? Colors.red.shade400
                                        : Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              loading: () => const SizedBox(width: 42),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _shareWord(context, word),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.share_rounded,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Language badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isHindi ? 'Hindi' : 'English',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Word
                    Text(
                      word.word,
                      style: (isHindi
                              ? AppTypography.hindiTitle
                              : AppTypography.wordTitle)
                          .copyWith(color: Colors.white),
                    ),

                    // Pronunciation
                    if (word.pronunciationIpa != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '/${word.pronunciationIpa}/',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],

                    // Part of speech
                    if (word.pos != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          word.formattedPos,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content sections
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Translations
              if (word.hasTranslationsTo(targetLanguage.code)) ...[
                TranslationSection(
                  translations: word.getTranslations(targetLanguage.code),
                  targetLanguage: targetLanguage,
                ),
                const SizedBox(height: 16),
              ],

              // Definitions
              if (word.definitions.isNotEmpty) ...[
                DefinitionCard(
                  definitions: word.definitions,
                  pos: word.pos,
                ),
                const SizedBox(height: 16),
              ],

              // Examples
              if (word.examples.isNotEmpty) ...[
                ExamplesSection(examples: word.examples),
                const SizedBox(height: 16),
              ],

              // Etymology
              if (word.etymology != null && word.etymology!.isNotEmpty) ...[
                _EtymologySection(etymology: word.etymology!),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  void _shareWord(BuildContext context, WordEntry word) {
    final buffer = StringBuffer();
    buffer.writeln('${word.word} (${word.isEnglish ? "English" : "Hindi"})');

    if (word.pronunciationIpa != null) {
      buffer.writeln('/${word.pronunciationIpa}/');
    }

    if (word.pos != null) {
      buffer.writeln('[${word.formattedPos}]');
    }

    if (word.definitions.isNotEmpty) {
      buffer.writeln();
      for (var i = 0; i < word.definitions.length && i < 3; i++) {
        buffer.writeln('${i + 1}. ${word.definitions[i]}');
      }
    }

    buffer.writeln();
    buffer.write('— WordBridge Dictionary');

    Share.share(buffer.toString());
  }
}

class _EtymologySection extends StatelessWidget {
  final String etymology;

  const _EtymologySection({required this.etymology});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.subtleShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.history_edu_rounded,
                    size: 18, color: Colors.purple.shade400),
              ),
              const SizedBox(width: 10),
              Text(
                'Etymology',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            etymology,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryC,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
