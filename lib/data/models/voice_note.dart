class VoiceNote {
  final String id;
  final String? audioPath; // null = audio backup off (default in v0.1)
  final String transcript;
  final String language;   // "es" | "en" as spoken
  final int durationMs;
  final DateTime createdAt;

  const VoiceNote({
    required this.id,
    this.audioPath,
    required this.transcript,
    required this.language,
    required this.durationMs,
    required this.createdAt,
  });
}
