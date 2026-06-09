import 'package:drift/drift.dart';
import '../../models/item.dart';
import 'voice_notes.dart';

class ItemTypeConverter extends TypeConverter<ItemType, String> {
  const ItemTypeConverter();

  @override
  ItemType fromSql(String fromDb) => ItemType.values.byName(fromDb);

  @override
  String toSql(ItemType value) => value.name;
}

@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get voiceNoteId =>
      text().references(VoiceNotes, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text().map(const ItemTypeConverter())();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get person => text().nullable()();
  RealColumn get confidence => real()();
  BoolColumn get needsReview => boolean()();
  BoolColumn get isDone =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isSaved =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get googleEventId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
