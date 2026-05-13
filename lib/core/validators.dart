class Validators {
  Validators._();

  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required.';
    if (v.trim().length < 2) return 'Minimum 2 characters.';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim()))
      return 'Invalid email format.';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Minimum 6 characters.';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password.';
    if (v != original) return 'Passwords do not match.';
    return null;
  }
}
