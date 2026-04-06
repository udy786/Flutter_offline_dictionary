import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../providers/search_provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/search_results_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      if (widget.initialQuery.isNotEmpty) {
        ref.read(searchProvider.notifier).searchNow(widget.initialQuery);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final languagePair = ref.watch(languagePairProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
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
                  // Back button
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.textPrimaryC,
                  ),

                  // Search field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: context.searchFieldBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: true,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: context.textPrimaryC,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Search ${languagePair.source.englishName} words...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onChanged: (value) {
                                ref
                                    .read(searchProvider.notifier)
                                    .updateQuery(value);
                                setState(() {});
                              },
                              onSubmitted: (value) {
                                ref
                                    .read(searchProvider.notifier)
                                    .searchNow(value);
                              },
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                          if (_controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _controller.clear();
                                ref.read(searchProvider.notifier).clear();
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Language badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      languagePair.shortDisplayString,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196F3),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Results body
            Expanded(
              child: _buildBody(searchState, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state, ThemeData theme) {
    if (state.query.isEmpty) {
      return _EmptyQueryView();
    }

    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryC,
              ),
            ),
          ],
        ),
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
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: context.textSecondaryC,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return _NoResultsView(query: state.query);
    }

    return SearchResultsList(
      results: state.results,
      onResultTap: (result) {
        context.push('/word/${result.wordId}');
      },
    );
  }
}

class _EmptyQueryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.translate_rounded,
                size: 44,
                color: const Color(0xFF2196F3).withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start typing to search',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textSecondaryC,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search in English or Hindi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.textSecondaryC,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final String query;

  const _NoResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Colors.orange.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryC,
                ),
                children: [
                  const TextSpan(text: 'No words matching "'),
                  TextSpan(
                    text: query,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '" were found.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.dividerC),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondaryC,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _suggestionRow(Icons.spellcheck_rounded, 'Different spelling'),
                  const SizedBox(height: 6),
                  _suggestionRow(Icons.swap_horiz_rounded, 'Search in the other language'),
                  const SizedBox(height: 6),
                  _suggestionRow(Icons.short_text_rounded, 'Fewer characters'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionRow(IconData icon, String text) {
    return Builder(builder: (context) {
      return Row(
        children: [
          Icon(icon, size: 16, color: context.textSecondaryC),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryC,
            ),
          ),
        ],
      );
    });
  }
}
