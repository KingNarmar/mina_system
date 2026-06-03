enum AppEnvironmentType { development, production }

abstract final class AppEnvironment {
  static const String _environmentName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String passwordResetRedirectUrl = String.fromEnvironment(
    'PASSWORD_RESET_REDIRECT_URL',
  );

  static const String _supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get supabaseAnonKey {
    final publishableKey = _supabasePublishableKey.trim();

    if (publishableKey.isNotEmpty) {
      return publishableKey;
    }

    return _supabaseAnonKey.trim();
  }

  static AppEnvironmentType get type {
    final normalizedEnvironment = _environmentName.trim().toLowerCase();

    return switch (normalizedEnvironment) {
      'production' || 'prod' => AppEnvironmentType.production,
      _ => AppEnvironmentType.development,
    };
  }

  static String get name {
    return switch (type) {
      AppEnvironmentType.development => 'development',
      AppEnvironmentType.production => 'production',
    };
  }

  static bool get isDevelopment => type == AppEnvironmentType.development;

  static bool get isProduction => type == AppEnvironmentType.production;

  static void validate() {
    final missingValues = <String>[];

    if (supabaseUrl.trim().isEmpty) {
      missingValues.add('SUPABASE_URL');
    }

    if (supabaseAnonKey.trim().isEmpty) {
      missingValues.add('SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY');
    }

    if (isProduction && passwordResetRedirectUrl.trim().isEmpty) {
      missingValues.add('PASSWORD_RESET_REDIRECT_URL');
    }

    if (missingValues.isNotEmpty) {
      throw StateError(
        'Missing required environment configuration: '
        '${missingValues.join(', ')}. '
        'Pass them using --dart-define.',
      );
    }

    final parsedSupabaseUrl = Uri.tryParse(supabaseUrl.trim());

    if (parsedSupabaseUrl == null ||
        parsedSupabaseUrl.scheme != 'https' ||
        parsedSupabaseUrl.host.trim().isEmpty) {
      throw StateError('SUPABASE_URL must be a valid HTTPS URL.');
    }

    final parsedPasswordResetRedirectUrl = Uri.tryParse(
      passwordResetRedirectUrl.trim(),
    );

    if (passwordResetRedirectUrl.trim().isNotEmpty &&
        (parsedPasswordResetRedirectUrl == null ||
            parsedPasswordResetRedirectUrl.scheme != 'https' ||
            parsedPasswordResetRedirectUrl.host.trim().isEmpty)) {
      throw StateError(
        'PASSWORD_RESET_REDIRECT_URL must be a valid HTTPS URL.',
      );
    }
  }
}
