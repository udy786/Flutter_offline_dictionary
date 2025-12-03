import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_result.dart';
import 'dictionary_providers.dart';
import 'settings_provider.dart';

/// Search state
class SearchState {
  final String query;
  final List<SearchResultEntity> results;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<SearchResultEntity>? results,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasResults => results.isNotEmpty;
  bool get isEmpty => query.isNotEmpty && results.isEmpty && !isLoading;
}

/// Search notifier for managing search state
class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounceTimer;

  SearchNotifier(this._ref) : super(const SearchState());

  /// Update search query with debouncing
  void updateQuery(String query) {
    state = state.copyWith(query: query, isLoading: query.isNotEmpty);

    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// Perform search immediately
  Future<void> searchNow(String query) async {
    _debounceTimer?.cancel();
    state = state.copyWith(query: query, isLoading: true);
    await _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    try {
      final repository = _ref.read(dictionaryRepositoryProvider);
      final languagePair = _ref.read(languagePairProvider);

      final results = await repository.search(
        query,
        sourceLanguage: languagePair.source.code,
        targetLanguage: languagePair.target.code,
      );

      // Only update if query hasn't changed
      if (state.query == query) {
        state = state.copyWith(results: results, isLoading: false, error: null);
      }
    } catch (e) {
      if (state.query == query) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  /// Clear search
  void clear() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Provider for search state
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

/// Provider for current search query
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(searchProvider).query;
});

/// Provider for search results
final currentSearchResultsProvider = Provider<List<SearchResultEntity>>((ref) {
  return ref.watch(searchProvider).results;
});

/// Provider for search loading state
final searchLoadingProvider = Provider<bool>((ref) {
  return ref.watch(searchProvider).isLoading;
});
