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

  static const String emailConfirmationRedirectUrl = String.fromEnvironment(
    'EMAIL_CONFIRMATION_REDIRECT_URL',
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

    if (isProduction && emailConfirmationRedirectUrl.trim().isEmpty) {
      missingValues.add('EMAIL_CONFIRMATION_REDIRECT_URL');
    }

    if (missingValues.isNotEmpty) {
      throw StateError(
        'Missing required environment configuration: '
        '${missingValues.join(', ')}. '
        'Pass them using --dart-define.',
      );
    }

    _validateHttpsUrl(
      value: supabaseUrl,
      variableName: 'SUPABASE_URL',
      required: true,
    );

    _validateHttpsUrl(
      value: passwordResetRedirectUrl,
      variableName: 'PASSWORD_RESET_REDIRECT_URL',
      required: false,
    );

    _validateHttpsUrl(
      value: emailConfirmationRedirectUrl,
      variableName: 'EMAIL_CONFIRMATION_REDIRECT_URL',
      required: false,
    );
  }

  static void _validateHttpsUrl({
    required String value,
    required String variableName,
    required bool required,
  }) {
    final normalizedValue = value.trim();

    if (!required && normalizedValue.isEmpty) {
      return;
    }

    final parsedUrl = Uri.tryParse(normalizedValue);

    if (parsedUrl == null ||
        parsedUrl.scheme != 'https' ||
        parsedUrl.host.trim().isEmpty) {
      throw StateError('$variableName must be a valid HTTPS URL.');
    }
  }
}
