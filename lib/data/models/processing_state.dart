import 'package:flutter/foundation.dart';
import 'item.dart';
import '../ai/dtos/extraction_response.dart';
import '../../core/uuid_factory.dart';

@immutable
class ReviewItem {
  final String tempId;
  final ItemType type;
  final String title;
  final DateTime? dateTime;
  final String? person;
  final String? note;
  final double confidence;
  final bool needsReview;
  final bool isSelected;
  final int? durationMinutes;

  const ReviewItem({
    required this.tempId,
    required this.type,
    required this.title,
    this.dateTime,
    this.person,
    this.note,
    required this.confidence,
    required this.needsReview,
    this.isSelected = true,
    this.durationMinutes,
  });

  ReviewItem copyWith({
    String? title,
    // Use nullable wrappers so callers can explicitly set a field to null.
    Object? dateTime = _sentinel,
    Object? person = _sentinel,
    Object? note = _sentinel,
    Object? durationMinutes = _sentinel,
    bool? isSelected,
  }) {
    return ReviewItem(
      tempId: tempId,
      type: type,
      title: title ?? this.title,
      dateTime: identical(dateTime, _sentinel)
          ? this.dateTime
          : dateTime as DateTime?,
      person: identical(person, _sentinel) ? this.person : person as String?,
      note: identical(note, _sentinel) ? this.note : note as String?,
      durationMinutes: identical(durationMinutes, _sentinel)
          ? this.durationMinutes
          : durationMinutes as int?,
      confidence: confidence,
      needsReview: needsReview,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory ReviewItem.fromExtracted(ExtractedItem item) => ReviewItem(
        tempId: newUuid(),
        type: item.type,
        title: item.title,
        dateTime: item.dateTime,
        person: item.person,
        note: item.note,
        confidence: item.confidence,
        needsReview: item.needsReview,
        durationMinutes: item.durationMinutes,
      );
}

// Sentinel for copyWith nullable fields.
const _sentinel = Object();

// ---------------------------------------------------------------------------
// Processing state machine (sealed — no loose bools)
// ---------------------------------------------------------------------------

sealed class ProcessingState {
  const ProcessingState();
}

final class Idle extends ProcessingState {
  const Idle();
}

final class Recording extends ProcessingState {
  final Duration elapsed;
  const Recording({required this.elapsed});
}

final class Transcribing extends ProcessingState {
  const Transcribing();
}

final class Extracting extends ProcessingState {
  final String transcript;
  // Carried so a network error during extraction can retry without re-transcribing.
  const Extracting({required this.transcript});
}

final class ReviewReady extends ProcessingState {
  final String voiceNoteId;
  final String transcript;
  final String language;
  final List<ReviewItem> items;
  final int durationMs;

  const ReviewReady({
    required this.voiceNoteId,
    required this.transcript,
    required this.language,
    required this.items,
    required this.durationMs,
  });
}

final class AutoSaved extends ProcessingState {
  final int scheduled;
  final int inbox;
  final int total;

  const AutoSaved({
    required this.scheduled,
    required this.inbox,
    required this.total,
  });
}

final class ProcessingError extends ProcessingState {
  final String message;
  final bool retryable;
  final String? savedTranscript; // non-null → retry skips re-transcription

  const ProcessingError({
    required this.message,
    required this.retryable,
    this.savedTranscript,
  });
}
