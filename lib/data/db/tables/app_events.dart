import 'package:drift/drift.dart';

@DataClassName('AppEventRow')
class AppEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get metaJson => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
