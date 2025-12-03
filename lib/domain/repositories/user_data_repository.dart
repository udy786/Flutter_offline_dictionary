import '../entities/word_entry.dart';

/// Data class for favorite entry
class FavoriteEntry {
  final int id;
  final WordEntry word;
  final DateTime createdAt;

  const FavoriteEntry({
    required this.id,
    required this.word,
    required this.createdAt,
  });
}

/// Data class for history entry
class HistoryEntry {
  final int id;
  final WordEntry word;
  final DateTime searchedAt;

  const HistoryEntry({
    required this.id,
    required this.word,
    required this.searchedAt,
  });
}

/// Abstract repository interface for user data operations
abstract class UserDataRepository {
  // ==================== FAVORITES ====================

  /// Add a word to favorites
  Future<void> addToFavorites(int wordId);

  /// Remove a word from favorites
  Future<void> removeFromFavorites(int wordId);

  /// Check if a word is in favorites
  Future<bool> isFavorite(int wordId);

  /// Get all favorites
  Future<List<FavoriteEntry>> getFavorites({int limit = 100, int offset = 0});

  /// Get favorites count
  Future<int> getFavoritesCount();

  /// Clear all favorites
  Future<void> clearFavorites();

  /// Watch if a specific word is favorite
  Stream<bool> watchIsFavorite(int wordId);

  // ==================== SEARCH HISTORY ====================

  /// Add a word to search history
  Future<void> addToHistory(int wordId);

  /// Get search history
  Future<List<HistoryEntry>> getHistory({int limit = 50, int offset = 0});

  /// Get recent searches (simplified)
  Future<List<WordEntry>> getRecentSearches({int limit = 10});

  /// Get history count
  Future<int> getHistoryCount();

  /// Clear search history
  Future<void> clearHistory();

  /// Remove a specific entry from history
  Future<void> removeFromHistory(int wordId);
}
