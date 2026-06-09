import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_database.dart';
import '../../core/uuid_factory.dart';
import 'capture_repository.dart';

part 'analytics_repository.g.dart';

@riverpod
AnalyticsRepository analyticsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsRepository(db);
}

class AnalyticsRepository {
  final AppDatabase _db;

  AnalyticsRepository(this._db);

  Future<void> logAppOpen() => _log('app_open');

  Future<void> logCaptureStarted() => _log('capture_started');

  Future<void> logCaptureSaved({
    required String voiceNoteId,
    required int proposed,
    required int saved,
  }) =>
      _log('capture_saved', meta: {
        'voiceNoteId': voiceNoteId,
        'proposed': proposed,
        'saved': saved,
      });

  Future<void> logCaptureDiscarded({required int proposed}) =>
      _log('capture_discarded', meta: {'proposed': proposed});

  Future<List<DateTime>> captureDays() => _db.analyticsDao.captureDays();

  Future<void> _log(String type, {Map<String, Object>? meta}) =>
      _db.analyticsDao.insertEvent(
        AppEventsCompanion.insert(
          id: newUuid(),
          type: type,
          timestamp: DateTime.now(),
          metaJson: Value(meta != null ? jsonEncode(meta) : null),
        ),
      );
}
