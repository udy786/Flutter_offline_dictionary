import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/word_entry.dart';
import '../../domain/repositories/user_data_repository.dart';
import 'dictionary_providers.dart';

/// History state
class HistoryState {
  final List<HistoryEntry> history;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<HistoryEntry>? history,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty => history.isEmpty && !isLoading;
  int get count => history.length;
}

/// History notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    loadHistory();
  }

  UserDataRepository get _repository => _ref.read(userDataRepositoryProvider);

  /// Load history from database
  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final history = await _repository.getHistory();
      state = state.copyWith(history: history, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add word to history (called when user views a word)
  Future<void> addToHistory(int wordId) async {
    try {
      await _repository.addToHistory(wordId);
      await loadHistory();
    } catch (e) {
      // Silently fail - history is not critical
    }
  }

  /// Remove entry from history
  Future<void> removeFromHistory(int wordId) async {
    try {
      await _repository.removeFromHistory(wordId);
      await loadHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _repository.clearHistory();
      state = state.copyWith(history: [], error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider for history state
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

/// Provider for recent searches (simplified list)
final recentSearchesProvider = FutureProvider<List<WordEntry>>((ref) async {
  final repository = ref.watch(userDataRepositoryProvider);
  return repository.getRecentSearches(limit: 10);
});
