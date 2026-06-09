import '../../../core/errors.dart';

class Transcript {
  final String text;

  const Transcript({required this.text});

  factory Transcript.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    if (text is! String || text.isEmpty) {
      throw const ParseError('Missing or empty text in transcription response');
    }
    return Transcript(text: text);
  }
}
