import 'package:drift/drift.dart';

/// Main table storing dictionary words
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get languageCode => text().withLength(min: 2, max: 10)();
  TextColumn get pos => text().nullable()(); // Part of speech
  TextColumn get pronunciationIpa => text().nullable()();
  TextColumn get etymology => text().nullable()();
  TextColumn get createdAt => text().nullable()(); // Store as text since DB has text timestamps

  @override
  List<Set<Column>> get uniqueKeys => [
        {word, languageCode, pos},
      ];
}

/// Definitions associated with a word
class Definitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  TextColumn get definition => text()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

/// Translations of a word to other languages
class Translations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceWordId => integer().references(Words, #id)();
  TextColumn get targetLanguageCode => text()();
  TextColumn get translation => text()();
}

/// Usage examples for a word
class Examples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  TextColumn get exampleText => text()();
}

/// User's favorite words
class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {wordId}
      ];
}

/// Search history
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get wordId => integer().references(Words, #id)();
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Metadata for database versioning
class Metadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
