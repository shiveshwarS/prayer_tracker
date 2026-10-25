abstract final class Validators {
  static String? name(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) {
      return 'Please enter your name.';
    }
    if (name.length < 2) {
      return 'Your name needs at least 2 characters.';
    }
    if (name.length > 50) {
      return 'Please use 50 characters or fewer.';
    }
    return null;
  }

  static String? phone(String? value, {int minDigits = 6, int maxDigits = 15}) {
    final String digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Please enter your phone number.';
    }
    if (digits.length < minDigits) {
      return 'That phone number looks too short.';
    }
    if (digits.length > maxDigits) {
      return 'That phone number looks too long.';
    }
    return null;
  }
}
