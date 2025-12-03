import 'package:equatable/equatable.dart';

/// Core business entity representing a dictionary word
class WordEntry extends Equatable {
  final int id;
  final String word;
  final String languageCode;
  final String? pos;
  final String? pronunciationIpa;
  final String? etymology;
  final List<String> definitions;
  final Map<String, List<String>> translations;
  final List<String> examples;
  final DateTime? createdAt;

  const WordEntry({
    required this.id,
    required this.word,
    required this.languageCode,
    this.pos,
    this.pronunciationIpa,
    this.etymology,
    this.definitions = const [],
    this.translations = const {},
    this.examples = const [],
    this.createdAt,
  });

  /// Get translations for a specific language
  List<String> getTranslations(String targetLanguage) {
    return translations[targetLanguage] ?? [];
  }

  /// Check if word has translations to a specific language
  bool hasTranslationsTo(String targetLanguage) {
    return translations[targetLanguage]?.isNotEmpty ?? false;
  }

  /// Check if word is in English
  bool get isEnglish => languageCode == 'en';

  /// Check if word is in Hindi
  bool get isHindi => languageCode == 'hi';

  /// Get primary definition
  String? get primaryDefinition => definitions.isNotEmpty ? definitions.first : null;

  /// Get formatted part of speech
  String get formattedPos {
    if (pos == null) return '';
    switch (pos!.toLowerCase()) {
      case 'noun':
        return 'noun';
      case 'verb':
        return 'verb';
      case 'adj':
      case 'adjective':
        return 'adjective';
      case 'adv':
      case 'adverb':
        return 'adverb';
      case 'pron':
      case 'pronoun':
        return 'pronoun';
      case 'prep':
      case 'preposition':
        return 'preposition';
      case 'conj':
      case 'conjunction':
        return 'conjunction';
      case 'intj':
      case 'interjection':
        return 'interjection';
      default:
        return pos!;
    }
  }

  @override
  List<Object?> get props => [
        id,
        word,
        languageCode,
        pos,
        pronunciationIpa,
        etymology,
        definitions,
        translations,
        examples,
        createdAt,
      ];

  WordEntry copyWith({
    int? id,
    String? word,
    String? languageCode,
    String? pos,
    String? pronunciationIpa,
    String? etymology,
    List<String>? definitions,
    Map<String, List<String>>? translations,
    List<String>? examples,
    DateTime? createdAt,
  }) {
    return WordEntry(
      id: id ?? this.id,
      word: word ?? this.word,
      languageCode: languageCode ?? this.languageCode,
      pos: pos ?? this.pos,
      pronunciationIpa: pronunciationIpa ?? this.pronunciationIpa,
      etymology: etymology ?? this.etymology,
      definitions: definitions ?? this.definitions,
      translations: translations ?? this.translations,
      examples: examples ?? this.examples,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
