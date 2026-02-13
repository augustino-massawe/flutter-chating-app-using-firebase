class Validators {
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? validateName(String? value) {
    return requiredField(value, 'Name');
  }

  static String? validateEmail(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    final email = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final required = requiredField(value, 'Password');
    if (required != null) return required;
    final password = value!.trim();
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? value, String passwordValue) {
    final required = requiredField(value, 'Confirm password');
    if (required != null) return required;
    if (value!.trim() != passwordValue.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }
}
