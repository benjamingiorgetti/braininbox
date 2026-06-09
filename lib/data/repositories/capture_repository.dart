import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_database.dart';
import '../models/processing_state.dart';
import '../services/google_calendar_service.dart';
import '../../core/notification_service.dart';
import '../../core/uuid_factory.dart';

part 'capture_repository.g.dart';

@riverpod
CaptureRepository captureRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final gcal = ref.watch(googleCalendarServiceProvider);
  return CaptureRepository(db, gcal);
}

@riverpod
AppDatabase appDatabase(Ref ref) => AppDatabase();

class CaptureRepository {
  final AppDatabase _db;
  final GoogleCalendarService _gcal;

  CaptureRepository(this._db, this._gcal);

  Future<void> saveCapture({
    required String voiceNoteId,
    required String transcript,
    required String language,
    required int durationMs,
    required List<ReviewItem> selectedItems,
  }) async {
    await _db.voiceNoteDao.insertVoiceNote(
      VoiceNotesCompanion.insert(
        id: voiceNoteId,
        transcript: transcript,
        language: language,
        durationMs: durationMs,
        createdAt: DateTime.now(),
      ),
    );

    final now = DateTime.now();
    final itemIds = <String>[];

    final companions = selectedItems.map((item) {
      final id = newUuid();
      itemIds.add(id);
      String? combinedNote = item.note;
      if (item.durationMinutes != null) {
        final durStr = '${item.durationMinutes} min';
        combinedNote = item.note != null ? '$durStr — ${item.note}' : durStr;
      }
      return ItemsCompanion.insert(
        id: id,
        voiceNoteId: voiceNoteId,
        type: item.type,
        title: item.title,
        note: Value(combinedNote),
        scheduledAt: Value(item.dateTime),
        person: Value(item.person),
        confidence: item.confidence,
        needsReview: item.needsReview,
        isSaved: const Value(true),
        createdAt: now,
      );
    }).toList();

    if (companions.isNotEmpty) {
      await _db.itemDao.insertItems(companions);
    }

    // Post-save: sync with Google Calendar and schedule notifications.
    final signedIn = await _gcal.isSignedInAsync;
    for (var i = 0; i < companions.length; i++) {
      final c = companions[i];
      final id = itemIds[i];
      final scheduledAt = c.scheduledAt.present ? c.scheduledAt.value : null;
      if (scheduledAt == null) continue;

      final title = c.title.value;
      final note = c.note.present ? c.note.value : null;

      // Schedule local notification.
      await NotificationService.scheduleItemNotification(
          id, title, scheduledAt);

      // Create Google Calendar event if signed in.
      if (signedIn) {
        final eventId = await _gcal.createEvent(
          title: title,
          note: note,
          scheduledAt: scheduledAt,
        );
        if (eventId != null) {
          await _db.itemDao.updateItem(
            ItemsCompanion(
              id: Value(id),
              googleEventId: Value(eventId),
            ),
          );
        }
      }
    }
  }
}
