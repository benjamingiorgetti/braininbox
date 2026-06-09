class CalendarEvent {
  final String googleId;
  final String title;
  final DateTime start;
  final DateTime? end;
  final bool isAllDay;
  final String? description;

  const CalendarEvent({
    required this.googleId,
    required this.title,
    required this.start,
    this.end,
    this.isAllDay = false,
    this.description,
  });
}
