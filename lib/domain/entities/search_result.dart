import 'package:equatable/equatable.dart';

/// Types of search matches
enum SearchMatchType {
  exact,
  prefix,
  fullText,
  translation,
}

/// Represents a search result from the dictionary
class SearchResultEntity extends Equatable {
  final int wordId;
  final String word;
  final String languageCode;
  final String? pos;
  final SearchMatchType matchType;
  final String? matchedTranslation;
  final String? previewDefinition;

  const SearchResultEntity({
    required this.wordId,
    required this.word,
    required this.languageCode,
    this.pos,
    required this.matchType,
    this.matchedTranslation,
    this.previewDefinition,
  });

  /// Check if this is an exact match
  bool get isExactMatch => matchType == SearchMatchType.exact;

  /// Check if word is in English
  bool get isEnglish => languageCode == 'en';

  /// Check if word is in Hindi
  bool get isHindi => languageCode == 'hi';

  @override
  List<Object?> get props => [
        wordId,
        word,
        languageCode,
        pos,
        matchType,
        matchedTranslation,
        previewDefinition,
      ];

  SearchResultEntity copyWith({
    int? wordId,
    String? word,
    String? languageCode,
    String? pos,
    SearchMatchType? matchType,
    String? matchedTranslation,
    String? previewDefinition,
  }) {
    return SearchResultEntity(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      languageCode: languageCode ?? this.languageCode,
      pos: pos ?? this.pos,
      matchType: matchType ?? this.matchType,
      matchedTranslation: matchedTranslation ?? this.matchedTranslation,
      previewDefinition: previewDefinition ?? this.previewDefinition,
    );
  }
}
