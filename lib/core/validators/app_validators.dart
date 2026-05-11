abstract class AppValidators {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 2) {
      return 'Full name is too short';
    }

    return null;
  }

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? validateEmailOrUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username is required';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
}
