import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;

import '../models/calendar_event.dart';

final googleCalendarServiceProvider = Provider<GoogleCalendarService>(
  (ref) => GoogleCalendarService(),
);

class GoogleCalendarService {
  final _googleSignIn = GoogleSignIn(
    scopes: [gcal.CalendarApi.calendarEventsScope],
    // Client ID is read from Info.plist (iOS) and google-services.json (Android).
    // See: https://pub.dev/packages/google_sign_in
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  String? get currentUserEmail => _googleSignIn.currentUser?.email;
  bool get isSignedIn => _googleSignIn.currentUser != null;
  Future<bool> get isSignedInAsync => _googleSignIn.isSignedIn();

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<gcal.CalendarApi?> _api() async {
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    if (account == null) return null;
    final headers = await account.authHeaders;
    return gcal.CalendarApi(_AuthClient(headers));
  }

  Future<String?> createEvent({
    required String title,
    String? note,
    required DateTime scheduledAt,
  }) async {
    final api = await _api();
    if (api == null) return null;
    try {
      final event = gcal.Event()
        ..summary = title
        ..description = note
        ..start = _toEventDateTime(scheduledAt)
        ..end = _toEventDateTime(scheduledAt.add(const Duration(hours: 1)));
      final created = await api.events.insert(event, 'primary');
      return created.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateEvent(
    String eventId, {
    bool? completed,
    String? title,
    DateTime? start,
  }) async {
    final api = await _api();
    if (api == null) return;
    try {
      final event = await api.events.get('primary', eventId);
      if (title != null) event.summary = title;
      if (start != null) {
        event.start = _toEventDateTime(start);
        event.end = _toEventDateTime(start.add(const Duration(hours: 1)));
      }
      if (completed == true) event.status = 'cancelled';
      if (completed == false && event.status == 'cancelled') {
        event.status = 'confirmed';
      }
      await api.events.update(event, 'primary', eventId);
    } catch (_) {
      // Event may have been deleted externally — silently ignore.
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final api = await _api();
    if (api == null) return;
    try {
      await api.events.delete('primary', eventId);
    } catch (_) {}
  }

  Future<List<CalendarEvent>> fetchEvents(DateTime start, DateTime end) async {
    final api = await _api();
    if (api == null) return [];
    try {
      final result = await api.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );
      return (result.items ?? [])
          .where((e) => e.id != null && e.summary != null)
          .map((e) => CalendarEvent(
                googleId: e.id!,
                title: e.summary!,
                start: _fromEventDateTime(e.start!),
                end: e.end != null ? _fromEventDateTime(e.end!) : null,
                isAllDay: e.start?.date != null,
                description: e.description,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  gcal.EventDateTime _toEventDateTime(DateTime dt) =>
      gcal.EventDateTime()..dateTime = dt.toUtc();

  DateTime _fromEventDateTime(gcal.EventDateTime edt) {
    if (edt.dateTime != null) return edt.dateTime!.toLocal();
    final d = edt.date!;
    return DateTime(d.year, d.month, d.day);
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _inner = http.Client();
  _AuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
