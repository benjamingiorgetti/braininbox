import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/app_events.dart';

part 'analytics_dao.g.dart';

@DriftAccessor(tables: [AppEvents])
class AnalyticsDao extends DatabaseAccessor<AppDatabase>
    with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  Future<void> insertEvent(AppEventsCompanion event) =>
      into(appEvents).insert(event);

  Future<List<AppEventRow>> exportEvents() =>
      (select(appEvents)
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();

  // Distinct days on which at least one capture was saved (for D1/D7 metric).
  Future<List<DateTime>> captureDays() async {
    final rows = await (select(appEvents)
          ..where((t) => t.type.equals('capture_saved'))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    final days = <DateTime>{};
    for (final row in rows) {
      days.add(DateTime(
        row.timestamp.year,
        row.timestamp.month,
        row.timestamp.day,
      ));
    }
    return days.toList();
  }
}
