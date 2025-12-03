import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/words_table.dart';
import 'daos/word_dao.dart';
import 'daos/search_dao.dart';
import 'daos/user_data_dao.dart';

part 'app_database.g.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be initialized in main.dart');
});

@DriftDatabase(
  tables: [
    Words,
    Definitions,
    Translations,
    Examples,
    Favorites,
    SearchHistory,
    Metadata,
  ],
  daos: [WordDao, SearchDao, UserDataDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create FTS5 virtual table for full-text search
        await customStatement('''
          CREATE VIRTUAL TABLE IF NOT EXISTS words_fts USING fts5(
            word,
            content='words',
            content_rowid='id',
            tokenize='unicode61'
          )
        ''');

        // Triggers to keep FTS in sync
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS words_ai AFTER INSERT ON words BEGIN
            INSERT INTO words_fts(rowid, word) VALUES (new.id, new.word);
          END
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS words_ad AFTER DELETE ON words BEGIN
            INSERT INTO words_fts(words_fts, rowid, word)
            VALUES ('delete', old.id, old.word);
          END
        ''');

        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS words_au AFTER UPDATE ON words BEGIN
            INSERT INTO words_fts(words_fts, rowid, word)
            VALUES ('delete', old.id, old.word);
            INSERT INTO words_fts(rowid, word) VALUES (new.id, new.word);
          END
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Get database version from metadata
  Future<String?> getDatabaseVersion() async {
    final result = await (select(metadata)
          ..where((t) => t.key.equals('version')))
        .getSingleOrNull();
    return result?.value;
  }

  /// Set database version in metadata
  Future<void> setDatabaseVersion(String version) async {
    await into(metadata).insertOnConflictUpdate(
      MetadataCompanion(
        key: const Value('version'),
        value: Value(version),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dictionary.db'));

    // If the database doesn't exist, copy from assets
    if (!await file.exists()) {
      await _copyDatabaseFromAssets(file);
    }

    return NativeDatabase.createInBackground(file);
  });
}

Future<void> _copyDatabaseFromAssets(File targetFile) async {
  try {
    // Try to load the database from assets
    final data = await rootBundle.load('assets/database/dictionary.db');
    final bytes = data.buffer.asUint8List();
    await targetFile.parent.create(recursive: true);
    await targetFile.writeAsBytes(bytes);
  } catch (e) {
    // If no asset database exists, create an empty one
    // This will be populated later
    await targetFile.parent.create(recursive: true);
    await targetFile.create();
  }
}
