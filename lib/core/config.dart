abstract final class AppConfig {
  static const openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const transcribeModel = String.fromEnvironment('TRANSCRIBE_MODEL',
      defaultValue: 'gpt-4o-mini-transcribe');
  static const extractModel =
      String.fromEnvironment('EXTRACT_MODEL', defaultValue: 'gpt-4o-mini');

  // Bias the transcription model toward domain-specific terms to reduce errors.
  static const transcriptionBiasPrompt =
      'MAU, LinkedIn, Notion, creatine, WhatsApp, Excel, newsletter, Slack, Airtable, iPhone, MacBook, Brain Inbox';

  // Google Calendar OAuth — configure client ID in Info.plist (iOS) and google-services.json (Android).
  // Pass via --dart-define=GOOGLE_CLIENT_ID=... only if targeting web or needing explicit override.
  static const googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');

  static const revenueCatApiKey = String.fromEnvironment('REVENUECAT_API_KEY');

  static const revenueCatEntitlementId = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT_ID',
    defaultValue: 'premium',
  );
}
