/// Centralised form validation.

class CVValidators {
  CVValidators._();

  static final _emailPattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static final _namePattern = RegExp(r"^[a-zA-Z\s.'-]+$");

  /// Digits only after stripping spaces, dashes and brackets.
  static final _phoneDigits = RegExp(r'^\+?[0-9]{9,15}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must contain at least one letter';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Name is too short';
    if (v.length > 50) return 'Name is too long';
    if (!_namePattern.hasMatch(v)) {
      return 'Name can only contain letters, spaces, apostrophes and hyphens';
    }
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Contact number is required';
    final cleaned = v.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phoneDigits.hasMatch(cleaned)) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter the verification code';
    if (v.length != length) return 'Code must be $length digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Code must be numbers only';
    return null;
  }

  /// Generic non-empty check for any other field.
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }
}
