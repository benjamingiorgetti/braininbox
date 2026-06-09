import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/voice_notes.dart';

part 'voice_note_dao.g.dart';

@DriftAccessor(tables: [VoiceNotes])
class VoiceNoteDao extends DatabaseAccessor<AppDatabase>
    with _$VoiceNoteDaoMixin {
  VoiceNoteDao(super.db);

  Future<void> insertVoiceNote(VoiceNotesCompanion note) =>
      into(voiceNotes).insert(note);

  Stream<List<VoiceNoteRow>> watchRecentNotes({int limit = 5}) =>
      (select(voiceNotes)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();

  Future<VoiceNoteRow?> findById(String id) =>
      (select(voiceNotes)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
}
