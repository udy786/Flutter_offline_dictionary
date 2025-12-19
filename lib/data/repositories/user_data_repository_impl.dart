import '../../domain/entities/word_entry.dart';
import '../../domain/repositories/user_data_repository.dart';
import '../database/app_database.dart';
import '../database/daos/user_data_dao.dart';
import '../database/daos/word_dao.dart';

/// Implementation of UserDataRepository using Drift database
class UserDataRepositoryImpl implements UserDataRepository {
  final AppDatabase _database;

  UserDataRepositoryImpl(this._database);

  UserDataDao get _userDataDao => _database.userDataDao;
  WordDao get _wordDao => _database.wordDao;

  // ==================== FAVORITES ====================

  @override
  Future<void> addToFavorites(int wordId) async {
    await _userDataDao.addToFavorites(wordId);
  }

  @override
  Future<void> removeFromFavorites(int wordId) async {
    await _userDataDao.removeFromFavorites(wordId);
  }

  @override
  Future<bool> isFavorite(int wordId) async {
    return _userDataDao.isFavorite(wordId);
  }

  @override
  Future<List<FavoriteEntry>> getFavorites({int limit = 100, int offset = 0}) async {
    final results = await _userDataDao.getFavorites(limit: limit, offset: offset);

    final entries = <FavoriteEntry>[];
    for (final result in results) {
      final wordDetails = await _wordDao.getWordById(result.word.id);
      if (wordDetails != null) {
        entries.add(FavoriteEntry(
          id: result.favorite.id,
          word: _mapToWordEntry(wordDetails),
          createdAt: result.favorite.createdAt,
        ));
      }
    }

    return entries;
  }

  @override
  Future<int> getFavoritesCount() async {
    return _userDataDao.getFavoritesCount();
  }

  @override
  Future<void> clearFavorites() async {
    await _userDataDao.clearFavorites();
  }

  @override
  Stream<bool> watchIsFavorite(int wordId) {
    return _userDataDao.watchIsFavorite(wordId);
  }

  // ==================== SEARCH HISTORY ====================

  @override
  Future<void> addToHistory(int wordId) async {
    await _userDataDao.addToHistory(wordId);
  }

  @override
  Future<List<HistoryEntry>> getHistory({int limit = 50, int offset = 0}) async {
    final results = await _userDataDao.getHistory(limit: limit, offset: offset);

    final entries = <HistoryEntry>[];
    for (final result in results) {
      final wordDetails = await _wordDao.getWordById(result.word.id);
      if (wordDetails != null) {
        entries.add(HistoryEntry(
          id: result.history.id,
          word: _mapToWordEntry(wordDetails),
          searchedAt: result.history.searchedAt,
        ));
      }
    }

    return entries;
  }

  @override
  Future<List<WordEntry>> getRecentSearches({int limit = 10}) async {
    final words = await _userDataDao.getRecentSearches(limit: limit);

    final entries = <WordEntry>[];
    for (final word in words) {
      final wordDetails = await _wordDao.getWordById(word.id);
      if (wordDetails != null) {
        entries.add(_mapToWordEntry(wordDetails));
      }
    }

    return entries;
  }

  @override
  Future<int> getHistoryCount() async {
    return _userDataDao.getHistoryCount();
  }

  @override
  Future<void> clearHistory() async {
    await _userDataDao.clearHistory();
  }

  @override
  Future<void> removeFromHistory(int wordId) async {
    await _userDataDao.removeFromHistory(wordId);
  }

  /// Map database WordWithDetails to domain WordEntry
  WordEntry _mapToWordEntry(WordWithDetails data) {
    // Group translations by target language
    final translationsMap = <String, List<String>>{};
    for (final trans in data.translations) {
      translationsMap.putIfAbsent(trans.targetLanguageCode, () => []);
      translationsMap[trans.targetLanguageCode]!.add(trans.translation);
    }

    return WordEntry(
      id: data.word.id,
      word: data.word.word,
      languageCode: data.word.languageCode,
      pos: data.word.pos,
      pronunciationIpa: data.word.pronunciationIpa,
      etymology: data.word.etymology,
      definitions: data.definitions.map((d) => d.definition).toList(),
      translations: translationsMap,
      examples: data.examples.map((e) => e.exampleText).toList(),
      createdAt: data.word.createdAt != null
          ? DateTime.tryParse(data.word.createdAt!)
          : null,
    );
  }
}
