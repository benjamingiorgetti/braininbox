import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_database.dart';
import '../models/inbox_filter.dart';
import '../models/item.dart';
import '../services/google_calendar_service.dart';
import '../../core/notification_service.dart';
import 'capture_repository.dart';

part 'inbox_repository.g.dart';

@riverpod
InboxRepository inboxRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final gcal = ref.watch(googleCalendarServiceProvider);
  return InboxRepository(db, gcal);
}

class InboxRepository {
  final AppDatabase _db;
  final GoogleCalendarService _gcal;

  InboxRepository(this._db, this._gcal);

  Stream<List<ItemRow>> watchInbox(InboxFilter filter) =>
      _db.itemDao.watchInbox(filter);

  Stream<int> watchPendingCount() => _db.itemDao.watchPendingCount();
  Stream<int> watchTotalSaved() => _db.itemDao.watchTotalSaved();
  Stream<int> watchDoneToday() => _db.itemDao.watchDoneToday();
  Stream<int> watchIdeasCount() => _db.itemDao.watchIdeasCount();
  Stream<int> watchTodayScheduledCount() =>
      _db.itemDao.watchTodayScheduledCount();
  Stream<int> watchTodayCompletedCount() =>
      _db.itemDao.watchTodayCompletedCount();

  Future<void> markDone(String id, {required bool done}) async {
    // Sync Google Calendar event status if linked.
    final item = await _db.itemDao.findById(id);
    if (item?.googleEventId != null && await _gcal.isSignedInAsync) {
      await _gcal.updateEvent(item!.googleEventId!, completed: done);
    }
    // Cancel or reschedule notification.
    if (done) await NotificationService.cancelNotification(id);

    await _db.itemDao.updateItem(ItemsCompanion(
      id: Value(id),
      isDone: Value(done),
    ));
  }

  Future<void> deleteItem(String id) async {
    // Clean up Google Calendar event if linked.
    final item = await _db.itemDao.findById(id);
    if (item?.googleEventId != null && await _gcal.isSignedInAsync) {
      await _gcal.deleteEvent(item!.googleEventId!);
    }
    await NotificationService.cancelNotification(id);
    await _db.itemDao.deleteItem(id);
  }

  Future<void> updateItemType(String id, ItemType type) =>
      _db.itemDao.updateItem(ItemsCompanion(
        id: Value(id),
        type: Value(type),
      ));

  Future<void> updateItem(
    String id, {
    String? title,
    DateTime? scheduledAt,
    String? person,
  }) async {
    final item = await _db.itemDao.findById(id);
    if (item == null) return;

    await _db.itemDao.updateItem(ItemsCompanion(
      id: Value(id),
      title: title != null ? Value(title) : const Value.absent(),
      scheduledAt:
          scheduledAt != null ? Value(scheduledAt) : const Value.absent(),
      person: person != null ? Value(person) : const Value.absent(),
    ));

    // Sync title/date change to Google Calendar.
    if (item.googleEventId != null && await _gcal.isSignedInAsync) {
      await _gcal.updateEvent(
        item.googleEventId!,
        title: title,
        start: scheduledAt,
      );
    }

    // Re-schedule notification if date changed.
    final newDate = scheduledAt ?? item.scheduledAt;
    final newTitle = title ?? item.title;
    if (newDate != null) {
      await NotificationService.cancelNotification(id);
      await NotificationService.scheduleItemNotification(id, newTitle, newDate);
    }
  }
}
