import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/processing_state.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/capture_repository.dart';
import '../capture/capture_controller.dart';

part 'review_controller.g.dart';

@riverpod
class ReviewController extends _$ReviewController {
  String _voiceNoteId = '';
  String _transcript = '';
  String _language = '';
  int _durationMs = 0;

  @override
  List<ReviewItem> build() {
    // Initialize from the capture controller's ReviewReady state.
    // Using ref.read so future capture state changes don't re-initialize this list.
    final captureState = ref.read(captureControllerProvider);
    if (captureState is ReviewReady) {
      _voiceNoteId = captureState.voiceNoteId;
      _transcript = captureState.transcript;
      _language = captureState.language;
      _durationMs = captureState.durationMs;
      return List<ReviewItem>.from(captureState.items);
    }
    return const [];
  }

  void toggleSelection(String tempId) {
    state = [
      for (final item in state)
        if (item.tempId == tempId)
          item.copyWith(isSelected: !item.isSelected)
        else
          item,
    ];
  }

  void quickEdit(
    String tempId, {
    String? title,
    Object? dateTime = _sentinel,
    Object? person = _sentinel,
  }) {
    state = [
      for (final item in state)
        if (item.tempId == tempId)
          item.copyWith(
            title: title,
            dateTime: dateTime,
            person: person,
          )
        else
          item,
    ];
  }

  void deleteItem(String tempId) {
    state = state.where((item) => item.tempId != tempId).toList();
  }

  // Returns true if save succeeded, false if nothing to save.
  Future<bool> saveAll() async {
    final selected = state.where((i) => i.isSelected).toList();
    if (selected.isEmpty) return false;

    await ref.read(captureRepositoryProvider).saveCapture(
          voiceNoteId: _voiceNoteId,
          transcript: _transcript,
          language: _language,
          durationMs: _durationMs,
          selectedItems: selected,
        );

    await ref.read(analyticsRepositoryProvider).logCaptureSaved(
          voiceNoteId: _voiceNoteId,
          proposed: state.length,
          saved: selected.length,
        );

    // Log discarded items count only when some were not saved.
    final discarded = state.length - selected.length;
    if (discarded > 0) {
      await ref
          .read(analyticsRepositoryProvider)
          .logCaptureDiscarded(proposed: discarded);
    }

    // Reset the capture flow so returning home starts fresh.
    ref.read(captureControllerProvider.notifier).reset();
    return true;
  }

  String get transcript => _transcript;
}

// Sentinel for nullable quickEdit params.
const _sentinel = Object();
