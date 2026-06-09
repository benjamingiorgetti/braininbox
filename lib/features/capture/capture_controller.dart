import 'dart:async';
import 'dart:io';

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors.dart';
import '../../core/uuid_factory.dart';
import '../../data/ai/openai_ai_service.dart';
import '../../data/models/item.dart';
import '../../data/models/processing_state.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/repositories/capture_repository.dart';

part 'capture_controller.g.dart';

// ---------------------------------------------------------------------------
// CaptureController
// Manages the full Record → Transcribe → Extract → Save state machine.
// The AI service is NEVER mocked — real OpenAI from day 1.
// ---------------------------------------------------------------------------

@riverpod
class CaptureController extends _$CaptureController {
  final _recorder = AudioRecorder();
  Timer? _timer;
  int _elapsedSeconds = 0;
  String? _tempAudioPath;
  int _recordingDurationMs = 0;
  DateTime? _recordingStartedAt;

  @override
  ProcessingState build() => const Idle();

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      state = const ProcessingError(
        message: 'Microphone access is required. Please enable it in Settings.',
        retryable: false,
      );
      return;
    }

    await ref.read(analyticsRepositoryProvider).logCaptureStarted();

    final dir = await getApplicationDocumentsDirectory();
    _tempAudioPath = '${dir.path}/capture_${newUuid()}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _tempAudioPath!,
    );

    _elapsedSeconds = 0;
    _recordingStartedAt = DateTime.now();
    state = const Recording(elapsed: Duration.zero);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      state = Recording(elapsed: Duration(seconds: _elapsedSeconds));
      // Cap at 2 minutes per spec — edge case: recording > 2 min.
      if (_elapsedSeconds >= 120) stopRecording(cappedByTimer: true);
    });
  }

  Future<void> stopRecording({bool cappedByTimer = false}) async {
    _timer?.cancel();
    _timer = null;

    final path = await _recorder.stop();
    if (path == null) {
      state = const ProcessingError(
        message: 'Recording failed. Please try again.',
        retryable: false,
      );
      return;
    }

    _recordingDurationMs = _recordingStartedAt != null
        ? DateTime.now().difference(_recordingStartedAt!).inMilliseconds
        : _elapsedSeconds * 1000;

    // Edge case: silent / too-short recording.
    if (_recordingDurationMs < 2000) {
      state = const ProcessingError(
        message: 'Recording too short. Speak for at least 2 seconds.',
        retryable: false,
      );
      return;
    }

    await _transcribeAndExtract(File(path));
  }

  // Share-sheet entry point: text already captured, skip recording entirely.
  Future<void> startFromSharedText(String text) async {
    _tempAudioPath = null;
    _recordingDurationMs = 0;
    await _extract(text);
  }

  Future<void> retry() async {
    final current = state;
    if (current is! ProcessingError) return;

    if (current.savedTranscript != null) {
      await _extract(current.savedTranscript!);
    } else if (_tempAudioPath != null) {
      await _transcribeAndExtract(File(_tempAudioPath!));
    } else {
      state = const Idle();
    }
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _elapsedSeconds = 0;
    _tempAudioPath = null;
    _recordingDurationMs = 0;
    _recordingStartedAt = null;
    state = const Idle();
  }

  // ---- private helpers ----

  Future<void> _transcribeAndExtract(File audioFile) async {
    state = const Transcribing();
    final ai = ref.read(aiServiceProvider);

    final String transcript;
    try {
      final result = await ai.transcribe(audioFile, languageHint: null);
      transcript = result.text;
    } on AiServiceError catch (e) {
      state = ProcessingError(message: _friendly(e), retryable: true);
      return;
    }

    await _extract(transcript);
  }

  Future<void> _extract(String transcript) async {
    state = Extracting(transcript: transcript);
    final ai = ref.read(aiServiceProvider);
    final now = DateTime.now();

    String tz;
    try {
      tz = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      tz = 'UTC';
    }

    try {
      final result = await ai.extractItems(transcript, now: now, tz: tz);
      final voiceNoteId = newUuid();
      final items = result.items.map(ReviewItem.fromExtracted).toList();
      await _saveAcceptedItems(
        voiceNoteId: voiceNoteId,
        transcript: transcript,
        language: result.language,
        items: items,
      );
    } on AiServiceError catch (e) {
      state = ProcessingError(
        message: _friendly(e),
        retryable: true,
        savedTranscript: transcript,
      );
    } catch (_) {
      state = ProcessingError(
        message: 'Could not save the extracted items. Tap Retry.',
        retryable: true,
        savedTranscript: transcript,
      );
    }
  }

  Future<void> _saveAcceptedItems({
    required String voiceNoteId,
    required String transcript,
    required String language,
    required List<ReviewItem> items,
  }) async {
    await ref.read(captureRepositoryProvider).saveCapture(
          voiceNoteId: voiceNoteId,
          transcript: transcript,
          language: language,
          durationMs: _recordingDurationMs,
          selectedItems: items,
        );

    await ref.read(analyticsRepositoryProvider).logCaptureSaved(
          voiceNoteId: voiceNoteId,
          proposed: items.length,
          saved: items.length,
        );

    final scheduled = items
        .where((item) => item.dateTime != null && item.type == ItemType.action)
        .length;
    final inbox = items.length - scheduled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'latest_capture_time',
      DateTime.now().toIso8601String(),
    );
    await prefs.setInt('latest_capture_scheduled', scheduled);
    await prefs.setInt('latest_capture_inbox', inbox);

    state = AutoSaved(
      scheduled: scheduled,
      inbox: inbox,
      total: items.length,
    );
  }

  static String _friendly(AiServiceError e) => switch (e) {
        NetworkError() =>
          'No internet connection. Check your network and tap Retry.',
        ApiError(:final statusCode) when statusCode == 401 =>
          'Invalid API key. Check your run configuration.',
        ApiError(:final statusCode) when statusCode == 429 =>
          'Rate limit reached. Wait a moment and tap Retry.',
        ApiError() => 'OpenAI returned an error. Tap Retry.',
        ParseError() => 'Unexpected AI response format. Tap Retry.',
      };
}
