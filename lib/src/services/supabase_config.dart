class SupabaseConfig {
  /// Public client settings injected with Flutter --dart-define.
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String mobileRedirect = 'io.knockquest.app://login-callback/';

  static bool get isConfigured =>
      Uri.tryParse(url)?.hasAuthority == true && anonKey.isNotEmpty;
}
