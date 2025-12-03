/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'Offline Dictionary';

  /// Database file name
  static const String databaseFileName = 'dictionary.db';

  /// Supported language codes
  static const List<String> supportedLanguages = ['en', 'hi'];

  /// Default search limit
  static const int defaultSearchLimit = 30;

  /// Default suggestions limit
  static const int defaultSuggestionsLimit = 10;

  /// Search debounce duration in milliseconds
  static const int searchDebounceDuration = 300;

  /// Maximum history items
  static const int maxHistoryItems = 100;

  /// Maximum recent searches shown on home
  static const int maxRecentSearches = 10;
}
