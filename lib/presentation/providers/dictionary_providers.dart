import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/dictionary_repository_impl.dart';
import '../../data/repositories/user_data_repository_impl.dart';
import '../../domain/entities/word_entry.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../../domain/repositories/user_data_repository.dart';
import 'settings_provider.dart';

/// Provider for DictionaryRepository
final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DictionaryRepositoryImpl(database);
});

/// Provider for UserDataRepository
final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return UserDataRepositoryImpl(database);
});

/// Provider for getting a word by ID
final wordByIdProvider = FutureProvider.family<WordEntry?, int>((ref, id) async {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return repository.getWordById(id);
});

/// Provider for search results
final searchResultsProvider = FutureProvider.family<List<SearchResultEntity>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(dictionaryRepositoryProvider);
  final languagePair = ref.watch(languagePairProvider);

  return repository.search(
    query,
    sourceLanguage: languagePair.source.code,
    targetLanguage: languagePair.target.code,
  );
});

/// Provider for search suggestions
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(dictionaryRepositoryProvider);
  final languagePair = ref.watch(languagePairProvider);

  return repository.getSuggestions(
    query,
    sourceLanguage: languagePair.source.code,
  );
});

/// Provider for database stats
final databaseStatsProvider = FutureProvider<DatabaseStats>((ref) async {
  final repository = ref.watch(dictionaryRepositoryProvider);

  final englishCount = await repository.getWordCount('en');
  final hindiCount = await repository.getWordCount('hi');
  final totalCount = await repository.getTotalWordCount();
  final version = await repository.getDatabaseVersion();

  return DatabaseStats(
    englishWordCount: englishCount,
    hindiWordCount: hindiCount,
    totalWordCount: totalCount,
    version: version,
  );
});

/// Database statistics
class DatabaseStats {
  final int englishWordCount;
  final int hindiWordCount;
  final int totalWordCount;
  final String? version;

  const DatabaseStats({
    required this.englishWordCount,
    required this.hindiWordCount,
    required this.totalWordCount,
    this.version,
  });
}
