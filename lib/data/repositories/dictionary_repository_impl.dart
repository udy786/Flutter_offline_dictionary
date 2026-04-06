import '../../core/services/profanity_filter.dart';
import '../../domain/entities/word_entry.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../database/app_database.dart';
import '../database/daos/word_dao.dart';
import '../database/daos/search_dao.dart';

/// Implementation of DictionaryRepository using Drift database
class DictionaryRepositoryImpl implements DictionaryRepository {
  final AppDatabase _database;

  DictionaryRepositoryImpl(this._database);

  WordDao get _wordDao => _database.wordDao;
  SearchDao get _searchDao => _database.searchDao;
  final _filter = ProfanityFilter.instance;

  @override
  Future<WordEntry?> getWordById(int id) async {
    final result = await _wordDao.getWordById(id);
    if (result == null) return null;
    return _mapToWordEntry(result);
  }

  @override
  Future<WordEntry?> getWordByText(String word, String languageCode) async {
    final result = await _wordDao.getWordByText(word, languageCode);
    if (result == null) return null;

    // Get full details
    final details = await _wordDao.getWordById(result.id);
    if (details == null) return null;

    return _mapToWordEntry(details);
  }

  @override
  Future<List<SearchResultEntity>> search(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    int limit = 30,
  }) async {
    final results = await _searchDao.search(
      query,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      limit: limit,
    );

    return results
        .map(_mapToSearchResult)
        .where((r) => !_filter.isOffensive(r.word))
        .toList();
  }

  @override
  Future<List<String>> getSuggestions(
    String query, {
    String? sourceLanguage,
    int limit = 10,
  }) async {
    final suggestions = await _searchDao.getSuggestions(
      query,
      sourceLanguage: sourceLanguage,
      limit: limit,
    );
    return suggestions.where((s) => !_filter.isOffensive(s)).toList();
  }

  @override
  Future<int> getWordCount(String languageCode) async {
    return _wordDao.getWordCount(languageCode);
  }

  @override
  Future<int> getTotalWordCount() async {
    return _wordDao.getTotalWordCount();
  }

  @override
  Future<String?> getDatabaseVersion() async {
    return _database.getDatabaseVersion();
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
      definitions: data.definitions.map((d) => d.definition).cast<String>().toList(),
      translations: translationsMap,
      examples: data.examples.map((e) => e.exampleText).cast<String>().toList(),
      createdAt: data.word.createdAt != null
          ? DateTime.tryParse(data.word.createdAt!)
          : null,
    );
  }

  /// Map database SearchResult to domain SearchResultEntity
  SearchResultEntity _mapToSearchResult(SearchResult data) {
    return SearchResultEntity(
      wordId: data.wordId,
      word: data.word,
      languageCode: data.languageCode,
      pos: data.pos,
      matchType: _mapMatchType(data.matchType),
      matchedTranslation: data.matchedTranslation,
    );
  }

  SearchMatchType _mapMatchType(MatchType type) {
    switch (type) {
      case MatchType.exact:
        return SearchMatchType.exact;
      case MatchType.prefix:
        return SearchMatchType.prefix;
      case MatchType.fullText:
        return SearchMatchType.fullText;
      case MatchType.translation:
        return SearchMatchType.translation;
    }
  }
}
