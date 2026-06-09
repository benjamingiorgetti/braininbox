enum ItemType { action, idea }

class Item {
  final String id;
  final String voiceNoteId;
  final ItemType type;
  final String title;
  final String? note;
  final DateTime? dateTime;
  final String? person;
  final double confidence;
  final bool needsReview;
  final bool isDone;
  final bool isSaved;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.voiceNoteId,
    required this.type,
    required this.title,
    this.note,
    this.dateTime,
    this.person,
    required this.confidence,
    required this.needsReview,
    required this.isDone,
    required this.isSaved,
    required this.createdAt,
  });

  Item copyWith({
    bool? isDone,
    bool? isSaved,
    String? title,
    String? Function()? note,
    DateTime? Function()? dateTime,
    String? Function()? person,
  }) {
    return Item(
      id: id,
      voiceNoteId: voiceNoteId,
      type: type,
      title: title ?? this.title,
      note: note != null ? note() : this.note,
      dateTime: dateTime != null ? dateTime() : this.dateTime,
      person: person != null ? person() : this.person,
      confidence: confidence,
      needsReview: needsReview,
      isDone: isDone ?? this.isDone,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt,
    );
  }
}
