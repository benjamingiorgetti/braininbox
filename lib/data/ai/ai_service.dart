import 'dart:io';
import 'dtos/transcription_response.dart';
import 'dtos/extraction_response.dart';

abstract interface class AiService {
  Future<Transcript> transcribe(File audio, {String? languageHint});

  Future<ExtractionResult> extractItems(
    String transcript, {
    required DateTime now,
    required String tz,
  });
}
