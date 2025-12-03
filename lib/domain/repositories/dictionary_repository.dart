import '../entities/word_entry.dart';
import '../entities/search_result.dart';

/// Abstract repository interface for dictionary operations
abstract class DictionaryRepository {
  /// Get a word by its ID with all related data
  Future<WordEntry?> getWordById(int id);

  /// Get a word by its text and language
  Future<WordEntry?> getWordByText(String word, String languageCode);

  /// Search for words
  Future<List<SearchResultEntity>> search(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    int limit = 30,
  });

  /// Get search suggestions for autocomplete
  Future<List<String>> getSuggestions(
    String query, {
    String? sourceLanguage,
    int limit = 10,
  });

  /// Get word count for a language
  Future<int> getWordCount(String languageCode);

  /// Get total word count
  Future<int> getTotalWordCount();

  /// Get database version
  Future<String?> getDatabaseVersion();
}
