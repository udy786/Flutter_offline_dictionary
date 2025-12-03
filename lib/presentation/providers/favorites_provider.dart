import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/user_data_repository.dart';
import 'dictionary_providers.dart';

/// Favorites state
class FavoritesState {
  final List<FavoriteEntry> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<FavoriteEntry>? favorites,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isEmpty => favorites.isEmpty && !isLoading;
  int get count => favorites.length;
}

/// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super(const FavoritesState()) {
    loadFavorites();
  }

  UserDataRepository get _repository => _ref.read(userDataRepositoryProvider);

  /// Load favorites from database
  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);

    try {
      final favorites = await _repository.getFavorites();
      state = state.copyWith(favorites: favorites, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add word to favorites
  Future<void> addToFavorites(int wordId) async {
    try {
      await _repository.addToFavorites(wordId);
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Remove word from favorites
  Future<void> removeFromFavorites(int wordId) async {
    try {
      await _repository.removeFromFavorites(wordId);
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int wordId) async {
    final isFav = await _repository.isFavorite(wordId);
    if (isFav) {
      await removeFromFavorites(wordId);
    } else {
      await addToFavorites(wordId);
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    try {
      await _repository.clearFavorites();
      state = state.copyWith(favorites: [], error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider for favorites state
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref);
});

/// Provider to check if a specific word is favorite
final isFavoriteProvider = FutureProvider.family<bool, int>((ref, wordId) async {
  final repository = ref.watch(userDataRepositoryProvider);
  return repository.isFavorite(wordId);
});

/// Stream provider to watch favorite status of a word
final watchIsFavoriteProvider = StreamProvider.family<bool, int>((ref, wordId) {
  final repository = ref.watch(userDataRepositoryProvider);
  return repository.watchIsFavorite(wordId);
});
