// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VoiceNotesTable extends VoiceNotes
    with TableInfo<$VoiceNotesTable, VoiceNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioPathMeta =
      const VerificationMeta('audioPath');
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
      'audio_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transcriptMeta =
      const VerificationMeta('transcript');
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
      'transcript', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, audioPath, transcript, language, durationMs, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_notes';
  @override
  VerificationContext validateIntegrity(Insertable<VoiceNoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audio_path')) {
      context.handle(_audioPathMeta,
          audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta));
    }
    if (data.containsKey('transcript')) {
      context.handle(
          _transcriptMeta,
          transcript.isAcceptableOrUnknown(
              data['transcript']!, _transcriptMeta));
    } else if (isInserting) {
      context.missing(_transcriptMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceNoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      audioPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_path']),
      transcript: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transcript'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VoiceNotesTable createAlias(String alias) {
    return $VoiceNotesTable(attachedDatabase, alias);
  }
}

class VoiceNoteRow extends DataClass implements Insertable<VoiceNoteRow> {
  final String id;
  final String? audioPath;
  final String transcript;
  final String language;
  final int durationMs;
  final DateTime createdAt;
  const VoiceNoteRow(
      {required this.id,
      this.audioPath,
      required this.transcript,
      required this.language,
      required this.durationMs,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['transcript'] = Variable<String>(transcript);
    map['language'] = Variable<String>(language);
    map['duration_ms'] = Variable<int>(durationMs);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoiceNotesCompanion toCompanion(bool nullToAbsent) {
    return VoiceNotesCompanion(
      id: Value(id),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      transcript: Value(transcript),
      language: Value(language),
      durationMs: Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceNoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceNoteRow(
      id: serializer.fromJson<String>(json['id']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      transcript: serializer.fromJson<String>(json['transcript']),
      language: serializer.fromJson<String>(json['language']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'audioPath': serializer.toJson<String?>(audioPath),
      'transcript': serializer.toJson<String>(transcript),
      'language': serializer.toJson<String>(language),
      'durationMs': serializer.toJson<int>(durationMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoiceNoteRow copyWith(
          {String? id,
          Value<String?> audioPath = const Value.absent(),
          String? transcript,
          String? language,
          int? durationMs,
          DateTime? createdAt}) =>
      VoiceNoteRow(
        id: id ?? this.id,
        audioPath: audioPath.present ? audioPath.value : this.audioPath,
        transcript: transcript ?? this.transcript,
        language: language ?? this.language,
        durationMs: durationMs ?? this.durationMs,
        createdAt: createdAt ?? this.createdAt,
      );
  VoiceNoteRow copyWithCompanion(VoiceNotesCompanion data) {
    return VoiceNoteRow(
      id: data.id.present ? data.id.value : this.id,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      transcript:
          data.transcript.present ? data.transcript.value : this.transcript,
      language: data.language.present ? data.language.value : this.language,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceNoteRow(')
          ..write('id: $id, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, audioPath, transcript, language, durationMs, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceNoteRow &&
          other.id == this.id &&
          other.audioPath == this.audioPath &&
          other.transcript == this.transcript &&
          other.language == this.language &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class VoiceNotesCompanion extends UpdateCompanion<VoiceNoteRow> {
  final Value<String> id;
  final Value<String?> audioPath;
  final Value<String> transcript;
  final Value<String> language;
  final Value<int> durationMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VoiceNotesCompanion({
    this.id = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.transcript = const Value.absent(),
    this.language = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceNotesCompanion.insert({
    required String id,
    this.audioPath = const Value.absent(),
    required String transcript,
    required String language,
    required int durationMs,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transcript = Value(transcript),
        language = Value(language),
        durationMs = Value(durationMs),
        createdAt = Value(createdAt);
  static Insertable<VoiceNoteRow> custom({
    Expression<String>? id,
    Expression<String>? audioPath,
    Expression<String>? transcript,
    Expression<String>? language,
    Expression<int>? durationMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audioPath != null) 'audio_path': audioPath,
      if (transcript != null) 'transcript': transcript,
      if (language != null) 'language': language,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceNotesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? audioPath,
      Value<String>? transcript,
      Value<String>? language,
      Value<int>? durationMs,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VoiceNotesCompanion(
      id: id ?? this.id,
      audioPath: audioPath ?? this.audioPath,
      transcript: transcript ?? this.transcript,
      language: language ?? this.language,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceNotesCompanion(')
          ..write('id: $id, ')
          ..write('audioPath: $audioPath, ')
          ..write('transcript: $transcript, ')
          ..write('language: $language, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _voiceNoteIdMeta =
      const VerificationMeta('voiceNoteId');
  @override
  late final GeneratedColumn<String> voiceNoteId = GeneratedColumn<String>(
      'voice_note_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES voice_notes (id) ON DELETE CASCADE'));
  @override
  late final GeneratedColumnWithTypeConverter<ItemType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ItemType>($ItemsTable.$convertertype);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
      'person', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _needsReviewMeta =
      const VerificationMeta('needsReview');
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
      'needs_review', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("needs_review" IN (0, 1))'));
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_done" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isSavedMeta =
      const VerificationMeta('isSaved');
  @override
  late final GeneratedColumn<bool> isSaved = GeneratedColumn<bool>(
      'is_saved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_saved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _googleEventIdMeta =
      const VerificationMeta('googleEventId');
  @override
  late final GeneratedColumn<String> googleEventId = GeneratedColumn<String>(
      'google_event_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        voiceNoteId,
        type,
        title,
        note,
        scheduledAt,
        person,
        confidence,
        needsReview,
        isDone,
        isSaved,
        createdAt,
        googleEventId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('voice_note_id')) {
      context.handle(
          _voiceNoteIdMeta,
          voiceNoteId.isAcceptableOrUnknown(
              data['voice_note_id']!, _voiceNoteIdMeta));
    } else if (isInserting) {
      context.missing(_voiceNoteIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('person')) {
      context.handle(_personMeta,
          person.isAcceptableOrUnknown(data['person']!, _personMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('needs_review')) {
      context.handle(
          _needsReviewMeta,
          needsReview.isAcceptableOrUnknown(
              data['needs_review']!, _needsReviewMeta));
    } else if (isInserting) {
      context.missing(_needsReviewMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('is_saved')) {
      context.handle(_isSavedMeta,
          isSaved.isAcceptableOrUnknown(data['is_saved']!, _isSavedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('google_event_id')) {
      context.handle(
          _googleEventIdMeta,
          googleEventId.isAcceptableOrUnknown(
              data['google_event_id']!, _googleEventIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      voiceNoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_note_id'])!,
      type: $ItemsTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      person: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      needsReview: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_review'])!,
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done'])!,
      isSaved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_saved'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      googleEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}google_event_id']),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<ItemType, String> $convertertype =
      const ItemTypeConverter();
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String voiceNoteId;
  final ItemType type;
  final String title;
  final String? note;
  final DateTime? scheduledAt;
  final String? person;
  final double confidence;
  final bool needsReview;
  final bool isDone;
  final bool isSaved;
  final DateTime createdAt;
  final String? googleEventId;
  const ItemRow(
      {required this.id,
      required this.voiceNoteId,
      required this.type,
      required this.title,
      this.note,
      this.scheduledAt,
      this.person,
      required this.confidence,
      required this.needsReview,
      required this.isDone,
      required this.isSaved,
      required this.createdAt,
      this.googleEventId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['voice_note_id'] = Variable<String>(voiceNoteId);
    {
      map['type'] = Variable<String>($ItemsTable.$convertertype.toSql(type));
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || person != null) {
      map['person'] = Variable<String>(person);
    }
    map['confidence'] = Variable<double>(confidence);
    map['needs_review'] = Variable<bool>(needsReview);
    map['is_done'] = Variable<bool>(isDone);
    map['is_saved'] = Variable<bool>(isSaved);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || googleEventId != null) {
      map['google_event_id'] = Variable<String>(googleEventId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      voiceNoteId: Value(voiceNoteId),
      type: Value(type),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      person:
          person == null && nullToAbsent ? const Value.absent() : Value(person),
      confidence: Value(confidence),
      needsReview: Value(needsReview),
      isDone: Value(isDone),
      isSaved: Value(isSaved),
      createdAt: Value(createdAt),
      googleEventId: googleEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(googleEventId),
    );
  }

  factory ItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      voiceNoteId: serializer.fromJson<String>(json['voiceNoteId']),
      type: serializer.fromJson<ItemType>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      person: serializer.fromJson<String?>(json['person']),
      confidence: serializer.fromJson<double>(json['confidence']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      isSaved: serializer.fromJson<bool>(json['isSaved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      googleEventId: serializer.fromJson<String?>(json['googleEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'voiceNoteId': serializer.toJson<String>(voiceNoteId),
      'type': serializer.toJson<ItemType>(type),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'person': serializer.toJson<String?>(person),
      'confidence': serializer.toJson<double>(confidence),
      'needsReview': serializer.toJson<bool>(needsReview),
      'isDone': serializer.toJson<bool>(isDone),
      'isSaved': serializer.toJson<bool>(isSaved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'googleEventId': serializer.toJson<String?>(googleEventId),
    };
  }

  ItemRow copyWith(
          {String? id,
          String? voiceNoteId,
          ItemType? type,
          String? title,
          Value<String?> note = const Value.absent(),
          Value<DateTime?> scheduledAt = const Value.absent(),
          Value<String?> person = const Value.absent(),
          double? confidence,
          bool? needsReview,
          bool? isDone,
          bool? isSaved,
          DateTime? createdAt,
          Value<String?> googleEventId = const Value.absent()}) =>
      ItemRow(
        id: id ?? this.id,
        voiceNoteId: voiceNoteId ?? this.voiceNoteId,
        type: type ?? this.type,
        title: title ?? this.title,
        note: note.present ? note.value : this.note,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        person: person.present ? person.value : this.person,
        confidence: confidence ?? this.confidence,
        needsReview: needsReview ?? this.needsReview,
        isDone: isDone ?? this.isDone,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt ?? this.createdAt,
        googleEventId:
            googleEventId.present ? googleEventId.value : this.googleEventId,
      );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      voiceNoteId:
          data.voiceNoteId.present ? data.voiceNoteId.value : this.voiceNoteId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      person: data.person.present ? data.person.value : this.person,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      needsReview:
          data.needsReview.present ? data.needsReview.value : this.needsReview,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      isSaved: data.isSaved.present ? data.isSaved.value : this.isSaved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      googleEventId: data.googleEventId.present
          ? data.googleEventId.value
          : this.googleEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('voiceNoteId: $voiceNoteId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('person: $person, ')
          ..write('confidence: $confidence, ')
          ..write('needsReview: $needsReview, ')
          ..write('isDone: $isDone, ')
          ..write('isSaved: $isSaved, ')
          ..write('createdAt: $createdAt, ')
          ..write('googleEventId: $googleEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      voiceNoteId,
      type,
      title,
      note,
      scheduledAt,
      person,
      confidence,
      needsReview,
      isDone,
      isSaved,
      createdAt,
      googleEventId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.voiceNoteId == this.voiceNoteId &&
          other.type == this.type &&
          other.title == this.title &&
          other.note == this.note &&
          other.scheduledAt == this.scheduledAt &&
          other.person == this.person &&
          other.confidence == this.confidence &&
          other.needsReview == this.needsReview &&
          other.isDone == this.isDone &&
          other.isSaved == this.isSaved &&
          other.createdAt == this.createdAt &&
          other.googleEventId == this.googleEventId);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> voiceNoteId;
  final Value<ItemType> type;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime?> scheduledAt;
  final Value<String?> person;
  final Value<double> confidence;
  final Value<bool> needsReview;
  final Value<bool> isDone;
  final Value<bool> isSaved;
  final Value<DateTime> createdAt;
  final Value<String?> googleEventId;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.voiceNoteId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.person = const Value.absent(),
    this.confidence = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.isDone = const Value.absent(),
    this.isSaved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.googleEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String voiceNoteId,
    required ItemType type,
    required String title,
    this.note = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.person = const Value.absent(),
    required double confidence,
    required bool needsReview,
    this.isDone = const Value.absent(),
    this.isSaved = const Value.absent(),
    required DateTime createdAt,
    this.googleEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        voiceNoteId = Value(voiceNoteId),
        type = Value(type),
        title = Value(title),
        confidence = Value(confidence),
        needsReview = Value(needsReview),
        createdAt = Value(createdAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? voiceNoteId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? scheduledAt,
    Expression<String>? person,
    Expression<double>? confidence,
    Expression<bool>? needsReview,
    Expression<bool>? isDone,
    Expression<bool>? isSaved,
    Expression<DateTime>? createdAt,
    Expression<String>? googleEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (voiceNoteId != null) 'voice_note_id': voiceNoteId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (person != null) 'person': person,
      if (confidence != null) 'confidence': confidence,
      if (needsReview != null) 'needs_review': needsReview,
      if (isDone != null) 'is_done': isDone,
      if (isSaved != null) 'is_saved': isSaved,
      if (createdAt != null) 'created_at': createdAt,
      if (googleEventId != null) 'google_event_id': googleEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? voiceNoteId,
      Value<ItemType>? type,
      Value<String>? title,
      Value<String?>? note,
      Value<DateTime?>? scheduledAt,
      Value<String?>? person,
      Value<double>? confidence,
      Value<bool>? needsReview,
      Value<bool>? isDone,
      Value<bool>? isSaved,
      Value<DateTime>? createdAt,
      Value<String?>? googleEventId,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      voiceNoteId: voiceNoteId ?? this.voiceNoteId,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      person: person ?? this.person,
      confidence: confidence ?? this.confidence,
      needsReview: needsReview ?? this.needsReview,
      isDone: isDone ?? this.isDone,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      googleEventId: googleEventId ?? this.googleEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (voiceNoteId.present) {
      map['voice_note_id'] = Variable<String>(voiceNoteId.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($ItemsTable.$convertertype.toSql(type.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (isSaved.present) {
      map['is_saved'] = Variable<bool>(isSaved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (googleEventId.present) {
      map['google_event_id'] = Variable<String>(googleEventId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('voiceNoteId: $voiceNoteId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('person: $person, ')
          ..write('confidence: $confidence, ')
          ..write('needsReview: $needsReview, ')
          ..write('isDone: $isDone, ')
          ..write('isSaved: $isSaved, ')
          ..write('createdAt: $createdAt, ')
          ..write('googleEventId: $googleEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppEventsTable extends AppEvents
    with TableInfo<$AppEventsTable, AppEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _metaJsonMeta =
      const VerificationMeta('metaJson');
  @override
  late final GeneratedColumn<String> metaJson = GeneratedColumn<String>(
      'meta_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, type, timestamp, metaJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_events';
  @override
  VerificationContext validateIntegrity(Insertable<AppEventRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('meta_json')) {
      context.handle(_metaJsonMeta,
          metaJson.isAcceptableOrUnknown(data['meta_json']!, _metaJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppEventRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      metaJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta_json']),
    );
  }

  @override
  $AppEventsTable createAlias(String alias) {
    return $AppEventsTable(attachedDatabase, alias);
  }
}

class AppEventRow extends DataClass implements Insertable<AppEventRow> {
  final String id;
  final String type;
  final DateTime timestamp;
  final String? metaJson;
  const AppEventRow(
      {required this.id,
      required this.type,
      required this.timestamp,
      this.metaJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || metaJson != null) {
      map['meta_json'] = Variable<String>(metaJson);
    }
    return map;
  }

  AppEventsCompanion toCompanion(bool nullToAbsent) {
    return AppEventsCompanion(
      id: Value(id),
      type: Value(type),
      timestamp: Value(timestamp),
      metaJson: metaJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metaJson),
    );
  }

  factory AppEventRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppEventRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      metaJson: serializer.fromJson<String?>(json['metaJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'metaJson': serializer.toJson<String?>(metaJson),
    };
  }

  AppEventRow copyWith(
          {String? id,
          String? type,
          DateTime? timestamp,
          Value<String?> metaJson = const Value.absent()}) =>
      AppEventRow(
        id: id ?? this.id,
        type: type ?? this.type,
        timestamp: timestamp ?? this.timestamp,
        metaJson: metaJson.present ? metaJson.value : this.metaJson,
      );
  AppEventRow copyWithCompanion(AppEventsCompanion data) {
    return AppEventRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      metaJson: data.metaJson.present ? data.metaJson.value : this.metaJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppEventRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('metaJson: $metaJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, timestamp, metaJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppEventRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.timestamp == this.timestamp &&
          other.metaJson == this.metaJson);
}

class AppEventsCompanion extends UpdateCompanion<AppEventRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> timestamp;
  final Value<String?> metaJson;
  final Value<int> rowid;
  const AppEventsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.metaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppEventsCompanion.insert({
    required String id,
    required String type,
    required DateTime timestamp,
    this.metaJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        timestamp = Value(timestamp);
  static Insertable<AppEventRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? timestamp,
    Expression<String>? metaJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (timestamp != null) 'timestamp': timestamp,
      if (metaJson != null) 'meta_json': metaJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<DateTime>? timestamp,
      Value<String?>? metaJson,
      Value<int>? rowid}) {
    return AppEventsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metaJson: metaJson ?? this.metaJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (metaJson.present) {
      map['meta_json'] = Variable<String>(metaJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppEventsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('metaJson: $metaJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VoiceNotesTable voiceNotes = $VoiceNotesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $AppEventsTable appEvents = $AppEventsTable(this);
  late final VoiceNoteDao voiceNoteDao = VoiceNoteDao(this as AppDatabase);
  late final ItemDao itemDao = ItemDao(this as AppDatabase);
  late final AnalyticsDao analyticsDao = AnalyticsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [voiceNotes, items, appEvents];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('voice_notes',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$VoiceNotesTableCreateCompanionBuilder = VoiceNotesCompanion Function({
  required String id,
  Value<String?> audioPath,
  required String transcript,
  required String language,
  required int durationMs,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$VoiceNotesTableUpdateCompanionBuilder = VoiceNotesCompanion Function({
  Value<String> id,
  Value<String?> audioPath,
  Value<String> transcript,
  Value<String> language,
  Value<int> durationMs,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$VoiceNotesTableReferences
    extends BaseReferences<_$AppDatabase, $VoiceNotesTable, VoiceNoteRow> {
  $$VoiceNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<ItemRow>> _itemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.items,
          aliasName:
              $_aliasNameGenerator(db.voiceNotes.id, db.items.voiceNoteId));

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager($_db, $_db.items)
        .filter((f) => f.voiceNoteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VoiceNotesTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> itemsRefs(
      Expression<bool> Function($$ItemsTableFilterComposer f) f) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.voiceNoteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableFilterComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VoiceNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioPath => $composableBuilder(
      column: $table.audioPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VoiceNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceNotesTable> {
  $$VoiceNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
      column: $table.transcript, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
      Expression<T> Function($$ItemsTableAnnotationComposer a) f) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.items,
        getReferencedColumn: (t) => t.voiceNoteId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.items,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VoiceNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VoiceNotesTable,
    VoiceNoteRow,
    $$VoiceNotesTableFilterComposer,
    $$VoiceNotesTableOrderingComposer,
    $$VoiceNotesTableAnnotationComposer,
    $$VoiceNotesTableCreateCompanionBuilder,
    $$VoiceNotesTableUpdateCompanionBuilder,
    (VoiceNoteRow, $$VoiceNotesTableReferences),
    VoiceNoteRow,
    PrefetchHooks Function({bool itemsRefs})> {
  $$VoiceNotesTableTableManager(_$AppDatabase db, $VoiceNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> audioPath = const Value.absent(),
            Value<String> transcript = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceNotesCompanion(
            id: id,
            audioPath: audioPath,
            transcript: transcript,
            language: language,
            durationMs: durationMs,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> audioPath = const Value.absent(),
            required String transcript,
            required String language,
            required int durationMs,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceNotesCompanion.insert(
            id: id,
            audioPath: audioPath,
            transcript: transcript,
            language: language,
            durationMs: durationMs,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$VoiceNotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData<VoiceNoteRow, $VoiceNotesTable,
                            ItemRow>(
                        currentTable: table,
                        referencedTable:
                            $$VoiceNotesTableReferences._itemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VoiceNotesTableReferences(db, table, p0)
                                .itemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.voiceNoteId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VoiceNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VoiceNotesTable,
    VoiceNoteRow,
    $$VoiceNotesTableFilterComposer,
    $$VoiceNotesTableOrderingComposer,
    $$VoiceNotesTableAnnotationComposer,
    $$VoiceNotesTableCreateCompanionBuilder,
    $$VoiceNotesTableUpdateCompanionBuilder,
    (VoiceNoteRow, $$VoiceNotesTableReferences),
    VoiceNoteRow,
    PrefetchHooks Function({bool itemsRefs})>;
typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String voiceNoteId,
  required ItemType type,
  required String title,
  Value<String?> note,
  Value<DateTime?> scheduledAt,
  Value<String?> person,
  required double confidence,
  required bool needsReview,
  Value<bool> isDone,
  Value<bool> isSaved,
  required DateTime createdAt,
  Value<String?> googleEventId,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> voiceNoteId,
  Value<ItemType> type,
  Value<String> title,
  Value<String?> note,
  Value<DateTime?> scheduledAt,
  Value<String?> person,
  Value<double> confidence,
  Value<bool> needsReview,
  Value<bool> isDone,
  Value<bool> isSaved,
  Value<DateTime> createdAt,
  Value<String?> googleEventId,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, ItemRow> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VoiceNotesTable _voiceNoteIdTable(_$AppDatabase db) =>
      db.voiceNotes.createAlias(
          $_aliasNameGenerator(db.items.voiceNoteId, db.voiceNotes.id));

  $$VoiceNotesTableProcessedTableManager get voiceNoteId {
    final $_column = $_itemColumn<String>('voice_note_id')!;

    final manager = $$VoiceNotesTableTableManager($_db, $_db.voiceNotes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_voiceNoteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ItemType, ItemType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsReview => $composableBuilder(
      column: $table.needsReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSaved => $composableBuilder(
      column: $table.isSaved, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleEventId => $composableBuilder(
      column: $table.googleEventId, builder: (column) => ColumnFilters(column));

  $$VoiceNotesTableFilterComposer get voiceNoteId {
    final $$VoiceNotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceNoteId,
        referencedTable: $db.voiceNotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VoiceNotesTableFilterComposer(
              $db: $db,
              $table: $db.voiceNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get person => $composableBuilder(
      column: $table.person, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsReview => $composableBuilder(
      column: $table.needsReview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSaved => $composableBuilder(
      column: $table.isSaved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleEventId => $composableBuilder(
      column: $table.googleEventId,
      builder: (column) => ColumnOrderings(column));

  $$VoiceNotesTableOrderingComposer get voiceNoteId {
    final $$VoiceNotesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceNoteId,
        referencedTable: $db.voiceNotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VoiceNotesTableOrderingComposer(
              $db: $db,
              $table: $db.voiceNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ItemType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<bool> get needsReview => $composableBuilder(
      column: $table.needsReview, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<bool> get isSaved =>
      $composableBuilder(column: $table.isSaved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get googleEventId => $composableBuilder(
      column: $table.googleEventId, builder: (column) => column);

  $$VoiceNotesTableAnnotationComposer get voiceNoteId {
    final $$VoiceNotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceNoteId,
        referencedTable: $db.voiceNotes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VoiceNotesTableAnnotationComposer(
              $db: $db,
              $table: $db.voiceNotes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemsTable,
    ItemRow,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (ItemRow, $$ItemsTableReferences),
    ItemRow,
    PrefetchHooks Function({bool voiceNoteId})> {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> voiceNoteId = const Value.absent(),
            Value<ItemType> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> person = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<bool> needsReview = const Value.absent(),
            Value<bool> isDone = const Value.absent(),
            Value<bool> isSaved = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> googleEventId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            voiceNoteId: voiceNoteId,
            type: type,
            title: title,
            note: note,
            scheduledAt: scheduledAt,
            person: person,
            confidence: confidence,
            needsReview: needsReview,
            isDone: isDone,
            isSaved: isSaved,
            createdAt: createdAt,
            googleEventId: googleEventId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String voiceNoteId,
            required ItemType type,
            required String title,
            Value<String?> note = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> person = const Value.absent(),
            required double confidence,
            required bool needsReview,
            Value<bool> isDone = const Value.absent(),
            Value<bool> isSaved = const Value.absent(),
            required DateTime createdAt,
            Value<String?> googleEventId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            id: id,
            voiceNoteId: voiceNoteId,
            type: type,
            title: title,
            note: note,
            scheduledAt: scheduledAt,
            person: person,
            confidence: confidence,
            needsReview: needsReview,
            isDone: isDone,
            isSaved: isSaved,
            createdAt: createdAt,
            googleEventId: googleEventId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ItemsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({voiceNoteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (voiceNoteId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.voiceNoteId,
                    referencedTable:
                        $$ItemsTableReferences._voiceNoteIdTable(db),
                    referencedColumn:
                        $$ItemsTableReferences._voiceNoteIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemsTable,
    ItemRow,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableAnnotationComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder,
    (ItemRow, $$ItemsTableReferences),
    ItemRow,
    PrefetchHooks Function({bool voiceNoteId})>;
typedef $$AppEventsTableCreateCompanionBuilder = AppEventsCompanion Function({
  required String id,
  required String type,
  required DateTime timestamp,
  Value<String?> metaJson,
  Value<int> rowid,
});
typedef $$AppEventsTableUpdateCompanionBuilder = AppEventsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<DateTime> timestamp,
  Value<String?> metaJson,
  Value<int> rowid,
});

class $$AppEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AppEventsTable> {
  $$AppEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metaJson => $composableBuilder(
      column: $table.metaJson, builder: (column) => ColumnFilters(column));
}

class $$AppEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppEventsTable> {
  $$AppEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metaJson => $composableBuilder(
      column: $table.metaJson, builder: (column) => ColumnOrderings(column));
}

class $$AppEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppEventsTable> {
  $$AppEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get metaJson =>
      $composableBuilder(column: $table.metaJson, builder: (column) => column);
}

class $$AppEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppEventsTable,
    AppEventRow,
    $$AppEventsTableFilterComposer,
    $$AppEventsTableOrderingComposer,
    $$AppEventsTableAnnotationComposer,
    $$AppEventsTableCreateCompanionBuilder,
    $$AppEventsTableUpdateCompanionBuilder,
    (AppEventRow, BaseReferences<_$AppDatabase, $AppEventsTable, AppEventRow>),
    AppEventRow,
    PrefetchHooks Function()> {
  $$AppEventsTableTableManager(_$AppDatabase db, $AppEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> metaJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppEventsCompanion(
            id: id,
            type: type,
            timestamp: timestamp,
            metaJson: metaJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required DateTime timestamp,
            Value<String?> metaJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppEventsCompanion.insert(
            id: id,
            type: type,
            timestamp: timestamp,
            metaJson: metaJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppEventsTable,
    AppEventRow,
    $$AppEventsTableFilterComposer,
    $$AppEventsTableOrderingComposer,
    $$AppEventsTableAnnotationComposer,
    $$AppEventsTableCreateCompanionBuilder,
    $$AppEventsTableUpdateCompanionBuilder,
    (AppEventRow, BaseReferences<_$AppDatabase, $AppEventsTable, AppEventRow>),
    AppEventRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VoiceNotesTableTableManager get voiceNotes =>
      $$VoiceNotesTableTableManager(_db, _db.voiceNotes);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$AppEventsTableTableManager get appEvents =>
      $$AppEventsTableTableManager(_db, _db.appEvents);
}
