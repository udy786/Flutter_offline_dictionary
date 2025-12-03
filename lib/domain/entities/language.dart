import 'package:equatable/equatable.dart';

/// Represents a supported language in the dictionary
class Language extends Equatable {
  final String code;
  final String nativeName;
  final String englishName;
  final String script;

  const Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.script,
  });

  /// English language constant
  static const english = Language(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    script: 'Latin',
  );

  /// Hindi language constant
  static const hindi = Language(
    code: 'hi',
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
    script: 'Devanagari',
  );

  /// Get all supported languages
  static List<Language> get supportedLanguages => [english, hindi];

  /// Get language by code
  static Language? fromCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }

  /// Check if language uses Devanagari script
  bool get isDevanagari => script == 'Devanagari';

  /// Check if language uses Latin script
  bool get isLatin => script == 'Latin';

  @override
  List<Object?> get props => [code, nativeName, englishName, script];
}

/// Represents a language pair for translation
class LanguagePair extends Equatable {
  final Language source;
  final Language target;

  const LanguagePair({
    required this.source,
    required this.target,
  });

  /// English to Hindi pair
  static const englishToHindi = LanguagePair(
    source: Language.english,
    target: Language.hindi,
  );

  /// Hindi to English pair
  static const hindiToEnglish = LanguagePair(
    source: Language.hindi,
    target: Language.english,
  );

  /// Swap source and target
  LanguagePair swap() {
    return LanguagePair(source: target, target: source);
  }

  /// Get display string
  String get displayString => '${source.nativeName} → ${target.nativeName}';

  /// Get short display string
  String get shortDisplayString => '${source.code.toUpperCase()} → ${target.code.toUpperCase()}';

  @override
  List<Object?> get props => [source, target];
}
