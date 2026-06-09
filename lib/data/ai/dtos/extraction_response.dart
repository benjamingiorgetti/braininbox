import '../../models/item.dart';
import '../../../core/errors.dart';

class ExtractedItem {
  final ItemType type;
  final String title;
  final String? note;
  final DateTime? dateTime;
  final String? person;
  final double confidence;
  final bool needsReview;
  final int? durationMinutes;

  const ExtractedItem({
    required this.type,
    required this.title,
    this.note,
    this.dateTime,
    this.person,
    required this.confidence,
    required this.needsReview,
    this.durationMinutes,
  });

  factory ExtractedItem.fromJson(
    Map<String, dynamic> json, {
    required DateTime now,
  }) {
    final typeStr = json['type'] as String?;
    final type = switch (typeStr) {
      'action' || 'goal' => ItemType.action,
      'idea' => ItemType.idea,
      _ => throw ParseError('Unknown item type: $typeStr'),
    };

    final title = json['title'];
    if (title is! String || title.isEmpty) {
      throw const ParseError('Missing or empty title in extracted item');
    }

    final note = json['note'] as String?;
    final person = json['person'] as String?;
    final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
    final durationMinutes = (json['durationMinutes'] as num?)?.toInt();
    bool needsReview = json['needsReview'] as bool? ?? false;

    // Parse dateTime and enforce contract rules:
    // - parse failure → null + needsReview
    // - past date → null + needsReview (the app double-checks the model)
    DateTime? dateTime;
    final dateTimeStr = json['dateTime'] as String?;
    if (dateTimeStr != null) {
      final parsed = DateTime.tryParse(dateTimeStr);
      if (parsed == null || parsed.isBefore(now)) {
        dateTime = null;
        needsReview = true;
      } else {
        dateTime = parsed;
      }
    }

    // Confidence threshold enforcement.
    if (confidence < 0.6) needsReview = true;

    return ExtractedItem(
      type: type,
      title: title,
      note: note,
      dateTime: dateTime,
      person: person,
      confidence: confidence,
      needsReview: needsReview,
      durationMinutes: durationMinutes,
    );
  }
}

class ExtractionResult {
  final String language;
  final List<ExtractedItem> items;

  const ExtractionResult({required this.language, required this.items});

  factory ExtractionResult.fromJson(
    Map<String, dynamic> json, {
    required DateTime now,
  }) {
    final language = json['language'] as String? ?? 'en';
    final itemsJson = json['items'] as List<dynamic>? ?? const <dynamic>[];
    final items = itemsJson
        .cast<Map<String, dynamic>>()
        .map((j) => ExtractedItem.fromJson(j, now: now))
        .toList();
    return ExtractionResult(language: language, items: items);
  }
}
