import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/words_table.dart';

part 'word_dao.g.dart';

@DriftAccessor(tables: [Words, Definitions, Translations, Examples])
class WordDao extends DatabaseAccessor<AppDatabase> with _$WordDaoMixin {
  WordDao(super.db);

  /// Get a word by ID with all related data
  Future<WordWithDetails?> getWordById(int id) async {
    final wordQuery = select(words)..where((w) => w.id.equals(id));
    final word = await wordQuery.getSingleOrNull();

    if (word == null) return null;

    final defs = await (select(definitions)
          ..where((d) => d.wordId.equals(id))
          ..orderBy([(d) => OrderingTerm.asc(d.orderIndex)]))
        .get();

    final trans = await (select(translations)
          ..where((t) => t.sourceWordId.equals(id)))
        .get();

    final exs = await (select(examples)..where((e) => e.wordId.equals(id)))
        .get();

    return WordWithDetails(
      word: word,
      definitions: defs,
      translations: trans,
      examples: exs,
    );
  }

  /// Get a word by its text and language
  Future<Word?> getWordByText(String wordText, String languageCode) async {
    final query = select(words)
      ..where((w) => w.word.equals(wordText) & w.languageCode.equals(languageCode));
    return query.getSingleOrNull();
  }

  /// Get all words for a specific language
  Future<List<Word>> getWordsByLanguage(String languageCode, {int limit = 100, int offset = 0}) async {
    final query = select(words)
      ..where((w) => w.languageCode.equals(languageCode))
      ..orderBy([(w) => OrderingTerm.asc(w.word)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  /// Get translations for a word to a specific target language
  Future<List<Translation>> getTranslationsForWord(int wordId, String targetLanguageCode) async {
    final query = select(translations)
      ..where((t) => t.sourceWordId.equals(wordId) & t.targetLanguageCode.equals(targetLanguageCode));
    return query.get();
  }

  /// Insert a new word with all related data
  Future<int> insertWordWithDetails({
    required WordsCompanion word,
    required List<DefinitionsCompanion> defs,
    required List<TranslationsCompanion> trans,
    required List<ExamplesCompanion> exs,
  }) async {
    return transaction(() async {
      final wordId = await into(words).insert(word);

      for (final def in defs) {
        await into(definitions).insert(def.copyWith(wordId: Value(wordId)));
      }

      for (final tran in trans) {
        await into(translations).insert(tran.copyWith(sourceWordId: Value(wordId)));
      }

      for (final ex in exs) {
        await into(examples).insert(ex.copyWith(wordId: Value(wordId)));
      }

      return wordId;
    });
  }

  /// Get word count for a language
  Future<int> getWordCount(String languageCode) async {
    final countExp = words.id.count();
    final query = selectOnly(words)
      ..addColumns([countExp])
      ..where(words.languageCode.equals(languageCode));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Get total word count
  Future<int> getTotalWordCount() async {
    final countExp = words.id.count();
    final query = selectOnly(words)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }
}

/// Data class to hold a word with all its related data
class WordWithDetails {
  final Word word;
  final List<Definition> definitions;
  final List<Translation> translations;
  final List<Example> examples;

  WordWithDetails({
    required this.word,
    required this.definitions,
    required this.translations,
    required this.examples,
  });
}
