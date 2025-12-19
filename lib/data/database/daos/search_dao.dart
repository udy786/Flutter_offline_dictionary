import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/words_table.dart';

part 'search_dao.g.dart';

@DriftAccessor(tables: [Words, Definitions, Translations])
class SearchDao extends DatabaseAccessor<AppDatabase> with _$SearchDaoMixin {
  SearchDao(super.db);

  /// Search words by prefix (fast, uses index)
  Future<List<SearchResult>> searchByPrefix(
    String query, {
    String? sourceLanguage,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final pattern = '$query%';
    var q = select(words)..where((w) => w.word.like(pattern));

    if (sourceLanguage != null) {
      q = q..where((w) => w.languageCode.equals(sourceLanguage));
    }

    q = q
      ..orderBy([(w) => OrderingTerm.asc(w.word)])
      ..limit(limit);

    final results = await q.get();
    return results
        .map((w) => SearchResult(
              wordId: w.id,
              word: w.word,
              languageCode: w.languageCode,
              pos: w.pos,
              matchType: MatchType.prefix,
            ))
        .toList();
  }

  /// Search words by exact match
  Future<List<SearchResult>> searchExact(
    String query, {
    String? sourceLanguage,
  }) async {
    if (query.isEmpty) return [];

    var q = select(words)..where((w) => w.word.equals(query.toLowerCase()));

    if (sourceLanguage != null) {
      q = q..where((w) => w.languageCode.equals(sourceLanguage));
    }

    final results = await q.get();
    return results
        .map((w) => SearchResult(
              wordId: w.id,
              word: w.word,
              languageCode: w.languageCode,
              pos: w.pos,
              matchType: MatchType.exact,
            ))
        .toList();
  }

  /// Full-text search using FTS5 (searches across word text)
  Future<List<SearchResult>> searchFullText(
    String query, {
    String? sourceLanguage,
    int limit = 50,
  }) async {
    if (query.isEmpty) return [];

    // Escape special FTS characters
    final escapedQuery = query.replaceAll('"', '""');

    String sql;
    List<Variable> variables;

    if (sourceLanguage != null) {
      sql = '''
        SELECT w.id, w.word, w.language_code, w.pos
        FROM words_fts fts
        JOIN words w ON w.id = fts.rowid
        WHERE words_fts MATCH ?
        AND w.language_code = ?
        ORDER BY rank
        LIMIT ?
      ''';
      variables = [Variable.withString('"$escapedQuery"*'), Variable.withString(sourceLanguage), Variable.withInt(limit)];
    } else {
      sql = '''
        SELECT w.id, w.word, w.language_code, w.pos
        FROM words_fts fts
        JOIN words w ON w.id = fts.rowid
        WHERE words_fts MATCH ?
        ORDER BY rank
        LIMIT ?
      ''';
      variables = [Variable.withString('"$escapedQuery"*'), Variable.withInt(limit)];
    }

    final results = await customSelect(sql, variables: variables).get();

    return results
        .map((row) => SearchResult(
              wordId: row.read<int>('id'),
              word: row.read<String>('word'),
              languageCode: row.read<String>('language_code'),
              pos: row.readNullable<String>('pos'),
              matchType: MatchType.fullText,
            ))
        .toList();
  }

  /// Search in translations (find words by their translations)
  Future<List<SearchResult>> searchInTranslations(
    String query, {
    required String sourceLanguage,
    required String targetLanguage,
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final pattern = '%$query%';

    final sql = '''
      SELECT DISTINCT w.id, w.word, w.language_code, w.pos, t.translation
      FROM words w
      JOIN translations t ON t.source_word_id = w.id
      WHERE w.language_code = ?
      AND t.target_language_code = ?
      AND t.translation LIKE ?
      ORDER BY w.word
      LIMIT ?
    ''';

    final results = await customSelect(sql, variables: [
      Variable.withString(sourceLanguage),
      Variable.withString(targetLanguage),
      Variable.withString(pattern),
      Variable.withInt(limit),
    ]).get();

    return results
        .map((row) => SearchResult(
              wordId: row.read<int>('id'),
              word: row.read<String>('word'),
              languageCode: row.read<String>('language_code'),
              pos: row.readNullable<String>('pos'),
              matchType: MatchType.translation,
              matchedTranslation: row.readNullable<String>('translation'),
            ))
        .toList();
  }

  /// Combined search: tries prefix first, then full-text, then translations
  Future<List<SearchResult>> search(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    int limit = 30,
  }) async {
    if (query.isEmpty) return [];

    final results = <SearchResult>[];
    final seenIds = <int>{};

    // 1. Exact match (highest priority)
    final exactResults = await searchExact(query, sourceLanguage: sourceLanguage);
    for (final r in exactResults) {
      if (!seenIds.contains(r.wordId)) {
        results.add(r);
        seenIds.add(r.wordId);
      }
    }

    // 2. Prefix match
    if (results.length < limit) {
      final prefixResults = await searchByPrefix(
        query,
        sourceLanguage: sourceLanguage,
        limit: limit - results.length,
      );
      for (final r in prefixResults) {
        if (!seenIds.contains(r.wordId)) {
          results.add(r);
          seenIds.add(r.wordId);
        }
      }
    }

    // 3. Full-text search (skip if fails - FTS might not be set up)
    if (results.length < limit) {
      try {
        final ftsResults = await searchFullText(
          query,
          sourceLanguage: sourceLanguage,
          limit: limit - results.length,
        );
        for (final r in ftsResults) {
          if (!seenIds.contains(r.wordId)) {
            results.add(r);
            seenIds.add(r.wordId);
          }
        }
      } catch (_) {
        // FTS search failed, continue without it
      }
    }

    // 4. Search in translations (if target language specified)
    if (results.length < limit && sourceLanguage != null && targetLanguage != null) {
      try {
        final transResults = await searchInTranslations(
          query,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          limit: limit - results.length,
        );
        for (final r in transResults) {
          if (!seenIds.contains(r.wordId)) {
            results.add(r);
            seenIds.add(r.wordId);
          }
        }
      } catch (_) {
        // Translation search failed, continue without it
      }
    }

    return results;
  }

  /// Get search suggestions (for autocomplete)
  Future<List<String>> getSuggestions(
    String query, {
    String? sourceLanguage,
    int limit = 10,
  }) async {
    if (query.isEmpty) return [];

    final results = await searchByPrefix(
      query,
      sourceLanguage: sourceLanguage,
      limit: limit,
    );

    return results.map((r) => r.word).toList();
  }
}

/// Types of matches found during search
enum MatchType {
  exact,
  prefix,
  fullText,
  translation,
}

/// Search result with metadata
class SearchResult {
  final int wordId;
  final String word;
  final String languageCode;
  final String? pos;
  final MatchType matchType;
  final String? matchedTranslation;

  SearchResult({
    required this.wordId,
    required this.word,
    required this.languageCode,
    this.pos,
    required this.matchType,
    this.matchedTranslation,
  });
}
