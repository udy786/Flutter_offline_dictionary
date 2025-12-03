import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/words_table.dart';

part 'user_data_dao.g.dart';

@DriftAccessor(tables: [Favorites, SearchHistory, Words])
class UserDataDao extends DatabaseAccessor<AppDatabase> with _$UserDataDaoMixin {
  UserDataDao(super.db);

  // ==================== FAVORITES ====================

  /// Add a word to favorites
  Future<void> addToFavorites(int wordId) async {
    await into(favorites).insertOnConflictUpdate(
      FavoritesCompanion(
        wordId: Value(wordId),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  /// Remove a word from favorites
  Future<void> removeFromFavorites(int wordId) async {
    await (delete(favorites)..where((f) => f.wordId.equals(wordId))).go();
  }

  /// Check if a word is in favorites
  Future<bool> isFavorite(int wordId) async {
    final result = await (select(favorites)
          ..where((f) => f.wordId.equals(wordId)))
        .getSingleOrNull();
    return result != null;
  }

  /// Get all favorites with word details
  Future<List<FavoriteWithWord>> getFavorites({int limit = 100, int offset = 0}) async {
    final query = select(favorites).join([
      innerJoin(words, words.id.equalsExp(favorites.wordId)),
    ])
      ..orderBy([OrderingTerm.desc(favorites.createdAt)])
      ..limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) {
      return FavoriteWithWord(
        favorite: row.readTable(favorites),
        word: row.readTable(words),
      );
    }).toList();
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    final countExp = favorites.id.count();
    final query = selectOnly(favorites)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    await delete(favorites).go();
  }

  // ==================== SEARCH HISTORY ====================

  /// Add a word to search history
  Future<void> addToHistory(int wordId) async {
    // Remove old entry if exists to update timestamp
    await (delete(searchHistory)..where((h) => h.wordId.equals(wordId))).go();

    await into(searchHistory).insert(
      SearchHistoryCompanion(
        wordId: Value(wordId),
        searchedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get search history with word details
  Future<List<HistoryWithWord>> getHistory({int limit = 50, int offset = 0}) async {
    final query = select(searchHistory).join([
      innerJoin(words, words.id.equalsExp(searchHistory.wordId)),
    ])
      ..orderBy([OrderingTerm.desc(searchHistory.searchedAt)])
      ..limit(limit, offset: offset);

    final results = await query.get();
    return results.map((row) {
      return HistoryWithWord(
        history: row.readTable(searchHistory),
        word: row.readTable(words),
      );
    }).toList();
  }

  /// Get recent searches (just words, no full details)
  Future<List<Word>> getRecentSearches({int limit = 10}) async {
    final query = select(searchHistory).join([
      innerJoin(words, words.id.equalsExp(searchHistory.wordId)),
    ])
      ..orderBy([OrderingTerm.desc(searchHistory.searchedAt)])
      ..limit(limit);

    final results = await query.get();
    return results.map((row) => row.readTable(words)).toList();
  }

  /// Get history count
  Future<int> getHistoryCount() async {
    final countExp = searchHistory.id.count();
    final query = selectOnly(searchHistory)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Clear search history
  Future<void> clearHistory() async {
    await delete(searchHistory).go();
  }

  /// Remove a specific entry from history
  Future<void> removeFromHistory(int wordId) async {
    await (delete(searchHistory)..where((h) => h.wordId.equals(wordId))).go();
  }

  // ==================== STREAMS (for reactive updates) ====================

  /// Watch favorites list
  Stream<List<FavoriteWithWord>> watchFavorites({int limit = 100}) {
    final query = select(favorites).join([
      innerJoin(words, words.id.equalsExp(favorites.wordId)),
    ])
      ..orderBy([OrderingTerm.desc(favorites.createdAt)])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        return FavoriteWithWord(
          favorite: row.readTable(favorites),
          word: row.readTable(words),
        );
      }).toList();
    });
  }

  /// Watch if a specific word is favorite
  Stream<bool> watchIsFavorite(int wordId) {
    final query = select(favorites)..where((f) => f.wordId.equals(wordId));
    return query.watchSingleOrNull().map((f) => f != null);
  }

  /// Watch search history
  Stream<List<HistoryWithWord>> watchHistory({int limit = 50}) {
    final query = select(searchHistory).join([
      innerJoin(words, words.id.equalsExp(searchHistory.wordId)),
    ])
      ..orderBy([OrderingTerm.desc(searchHistory.searchedAt)])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        return HistoryWithWord(
          history: row.readTable(searchHistory),
          word: row.readTable(words),
        );
      }).toList();
    });
  }
}

/// Favorite entry with associated word data
class FavoriteWithWord {
  final Favorite favorite;
  final Word word;

  FavoriteWithWord({
    required this.favorite,
    required this.word,
  });
}

/// History entry with associated word data
class HistoryWithWord {
  final SearchHistoryData history;
  final Word word;

  HistoryWithWord({
    required this.history,
    required this.word,
  });
}
