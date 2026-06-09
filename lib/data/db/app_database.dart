import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/item.dart';
import 'tables/voice_notes.dart';
import 'tables/items.dart';
import 'tables/app_events.dart';
import 'daos/voice_note_dao.dart';
import 'daos/item_dao.dart';
import 'daos/analytics_dao.dart';

export 'tables/items.dart' show ItemTypeConverter;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [VoiceNotes, Items, AppEvents],
  daos: [VoiceNoteDao, ItemDao, AnalyticsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'braininbox'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(items, items.googleEventId);
          }
        },
      );
}
