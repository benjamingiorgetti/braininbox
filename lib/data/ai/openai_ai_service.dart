import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config.dart';
import '../../core/errors.dart';
import 'ai_service.dart';
import 'dtos/transcription_response.dart';
import 'dtos/extraction_response.dart';

part 'openai_ai_service.g.dart';

@riverpod
AiService aiService(Ref ref) {
  assert(
    AppConfig.openaiApiKey.isNotEmpty,
    'OPENAI_API_KEY is not set. Pass it via --dart-define=OPENAI_API_KEY=...',
  );
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    headers: {'Authorization': 'Bearer ${AppConfig.openaiApiKey}'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));
  return OpenAiAiService(dio);
}

class OpenAiAiService implements AiService {
  final Dio _dio;

  const OpenAiAiService(this._dio);

  @override
  Future<Transcript> transcribe(File audio, {String? languageHint}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audio.path,
          filename: 'audio.m4a',
        ),
        'model': AppConfig.transcribeModel,
        'response_format': 'json',
        'prompt': AppConfig.transcriptionBiasPrompt,
        if (languageHint != null) 'language': languageHint,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/audio/transcriptions',
        data: formData,
      );

      final data = response.data;
      if (data == null) throw const ParseError('Empty transcription response');
      return Transcript.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on AiServiceError {
      rethrow;
    } catch (e) {
      throw ParseError(e.toString());
    }
  }

  @override
  Future<ExtractionResult> extractItems(
    String transcript, {
    required DateTime now,
    required String tz,
  }) async {
    final userContent =
        'transcript: $transcript\nnow: ${now.toIso8601String()}\ntz: $tz';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': AppConfig.extractModel,
          'response_format': {
            'type': 'json_schema',
            'json_schema': {
              'name': 'extraction',
              'strict': true,
              'schema': _extractionSchema,
            },
          },
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userContent},
          ],
        },
      );

      final data = response.data;
      if (data == null) throw const ParseError('Empty extraction response');
      final choices = data['choices'] as List<dynamic>?;
      final message =
          (choices?.first as Map<String, dynamic>?)?['message']
              as Map<String, dynamic>?;
      final content = message?['content'] as String?;
      if (content == null) {
        throw const ParseError('No content in extraction response');
      }
      final json = jsonDecode(content) as Map<String, dynamic>;
      return ExtractionResult.fromJson(json, now: now);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on AiServiceError {
      rethrow;
    } catch (e) {
      throw ParseError(e.toString());
    }
  }

  static AiServiceError _mapDioError(DioException e) {
    final type = e.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.sendTimeout) {
      return NetworkError(e.message ?? 'Network error');
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      return ApiError(
        statusCode: statusCode,
        body: e.response?.data?.toString() ?? '',
      );
    }
    return NetworkError(e.message ?? 'Unknown network error');
  }

  static const _systemPrompt =
      'You extract structured action items and ideas from spoken voice notes. '
      'Rules: '
      '1) Never invent data — if something was not said, the field is null. '
      '2) Resolve relative dates using now + tz; if ambiguous or would be in the past, set dateTime=null and needsReview=true. '
      '3) OUTPUT LANGUAGE — CRITICAL: NEVER translate. The title and note MUST be written in the EXACT same language the user spoke. If the transcript is in English, all titles and notes must be in English. If the transcript is in Spanish, all titles and notes must be in Spanish. Do NOT mix languages. Do NOT translate under any circumstances. '
      '4) Map to action (anything to-do) or idea (non-actionable). Set person when contacting someone; set dateTime when time-bound. '
      '5) Split compound utterances into separate items. '
      '6) If there is no actionable content, return items=[]. '
      '7) Set confidence < 0.6 and needsReview=true when extraction certainty is low. '
      '8) MULTI-DAY PLAN EXPANSION: When the user describes a preparation plan for a deadline (exam, meeting, delivery) with a repeated session pattern, generate ONE action item PER SESSION — not one generic task. Example: "3 days before Wednesday" → 3 separate action items, one on each of the 3 calendar days preceding Wednesday. Do NOT include the deadline day itself unless explicitly asked. '
      '9) GOAL/DEADLINE ITEMS: When the user mentions an exam, meeting, due date, or delivery deadline, generate a separate item with type="goal" for it (title = the event name, dateTime = the deadline date, needsReview=false if the date is clear). '
      '10) DURATION: Extract session duration exactly as stated; never invent. Set durationMinutes to the integer number of minutes. "media hora" or "30 minutos" → 30. "una hora" → 60. "45 minutos" → 45. If no duration is mentioned → null. '
      '11) TIME RULE: If a date is known but no time was stated, set dateTime to that date at 00:00 local time (ISO 8601 with +00:00 offset) and needsReview=true. '
      'Spanish date/time vocabulary: mañana=tomorrow, pasado mañana=day-after-tomorrow, el lunes/martes/miércoles/jueves/viernes/sábado/domingo=next occurrence of that weekday, tres días antes del examen=3 days before the deadline date, media hora=30 min, cada día/por día=expand into multiple items (one per day), hasta el parcial=until (not including) the exam date, de lunes a miércoles=Monday+Tuesday+Wednesday.';

  static const _extractionSchema = <String, Object>{
    'type': 'object',
    'required': ['language', 'items'],
    'additionalProperties': false,
    'properties': {
      'language': {'type': 'string'},
      'items': {
        'type': 'array',
        'items': {
          'type': 'object',
          'required': [
            'type',
            'title',
            'note',
            'dateTime',
            'person',
            'confidence',
            'needsReview',
            'durationMinutes',
          ],
          'additionalProperties': false,
          'properties': {
            'type': {
              'type': 'string',
              'enum': ['action', 'idea'],
            },
            'title': {'type': 'string'},
            'note': {
              'type': ['string', 'null'],
            },
            'dateTime': {
              'type': ['string', 'null'],
            },
            'person': {
              'type': ['string', 'null'],
            },
            'confidence': {'type': 'number'},
            'needsReview': {'type': 'boolean'},
            'durationMinutes': {
              'type': ['integer', 'null'],
            },
          },
        },
      },
    },
  };
}
