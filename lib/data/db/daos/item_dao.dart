import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/items.dart';
import '../../../core/datetime_helpers.dart';
import '../../models/inbox_filter.dart';

part 'item_dao.g.dart';

@DriftAccessor(tables: [Items])
class ItemDao extends DatabaseAccessor<AppDatabase> with _$ItemDaoMixin {
  ItemDao(super.db);

  Future<void> insertItems(List<ItemsCompanion> companions) =>
      batch((b) => b.insertAll(items, companions));

  Future<void> updateItem(ItemsCompanion companion) =>
      (update(items)..where((t) => t.id.equals(companion.id.value)))
          .write(companion);

  Future<ItemRow?> findById(String id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteItem(String id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  Stream<List<ItemRow>> watchInbox(InboxFilter filter) {
    final now = DateTime.now();
    final todayStart = startOfDay(now);
    final todayEnd = endOfDay(now);

    switch (filter) {
      case InboxFilter.today:
        return (select(items)
              ..where((t) =>
                  t.isSaved.equals(true) &
                  t.isDone.equals(false) &
                  t.scheduledAt.isBetweenValues(todayStart, todayEnd))
              ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
            .watch();
      case InboxFilter.upcoming:
        return (select(items)
              ..where((t) =>
                  t.isSaved.equals(true) &
                  t.isDone.equals(false) &
                  t.scheduledAt.isBiggerThanValue(todayEnd))
              ..orderBy([(t) => OrderingTerm.asc(t.scheduledAt)]))
            .watch();
      case InboxFilter.noDate:
        return (select(items)
              ..where((t) =>
                  t.isSaved.equals(true) &
                  t.isDone.equals(false) &
                  t.scheduledAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .watch();
      case InboxFilter.done:
        return (select(items)
              ..where((t) => t.isSaved.equals(true) & t.isDone.equals(true))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .watch();
      case InboxFilter.needsReview:
        return (select(items)
              ..where((t) =>
                  t.isSaved.equals(true) &
                  t.isDone.equals(false) &
                  (t.needsReview.equals(true) |
                      (t.scheduledAt.isNull() & t.type.equals('action'))))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .watch();
    }
  }

  Stream<int> watchPendingCount() => (selectOnly(items)
        ..addColumns([items.id.count()])
        ..where(items.isSaved.equals(true) & items.isDone.equals(false)))
      .map((row) => row.read(items.id.count()) ?? 0)
      .watchSingle();

  Stream<int> watchTotalSaved() => (selectOnly(items)
        ..addColumns([items.id.count()])
        ..where(items.isSaved.equals(true)))
      .map((row) => row.read(items.id.count()) ?? 0)
      .watchSingle();

  Stream<int> watchDoneToday() {
    final now = DateTime.now();
    return (selectOnly(items)
          ..addColumns([items.id.count()])
          ..where(
            items.isSaved.equals(true) &
                items.isDone.equals(true) &
                items.createdAt.isBetweenValues(startOfDay(now), endOfDay(now)),
          ))
        .map((row) => row.read(items.id.count()) ?? 0)
        .watchSingle();
  }

  Stream<int> watchIdeasCount() => (selectOnly(items)
        ..addColumns([items.id.count()])
        ..where(items.isSaved.equals(true) & items.type.equals('idea')))
      .map((row) => row.read(items.id.count()) ?? 0)
      .watchSingle();

  // All saved items (done or not) scheduled for today — denominator for progress.
  Stream<int> watchTodayScheduledCount() {
    final now = DateTime.now();
    return (selectOnly(items)
          ..addColumns([items.id.count()])
          ..where(
            items.isSaved.equals(true) &
                items.scheduledAt
                    .isBetweenValues(startOfDay(now), endOfDay(now)),
          ))
        .map((row) => row.read(items.id.count()) ?? 0)
        .watchSingle();
  }

  // Saved + done items scheduled for today — numerator for progress.
  Stream<int> watchTodayCompletedCount() {
    final now = DateTime.now();
    return (selectOnly(items)
          ..addColumns([items.id.count()])
          ..where(
            items.isSaved.equals(true) &
                items.isDone.equals(true) &
                items.scheduledAt
                    .isBetweenValues(startOfDay(now), endOfDay(now)),
          ))
        .map((row) => row.read(items.id.count()) ?? 0)
        .watchSingle();
  }
}
