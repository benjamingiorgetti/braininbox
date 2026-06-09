import 'package:drift/drift.dart';

@DataClassName('VoiceNoteRow')
class VoiceNotes extends Table {
  TextColumn get id => text()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get transcript => text()();
  TextColumn get language => text()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
