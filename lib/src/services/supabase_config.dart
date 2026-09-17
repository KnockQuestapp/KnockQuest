class SupabaseConfig {
  /// Replace these with real values from your Supabase project settings.
  static const String url = 'https://your-project-id.supabase.co';
  static const String anonKey = 'your-anon-key';

  static bool get isConfigured =>
      url != 'https://your-project-id.supabase.co' &&
      anonKey != 'your-anon-key';
}
