import 'dart:math';

/// Utility to generate, format, and parse cute alphanumeric room codes
/// e.g. "K9X2B7", "P4N8Q2", "PINK42"
class RoomCodeGenerator {
  // Characters that avoid visual ambiguity (excluding 'O', '0', 'I', '1')
  static const String _letters = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _numbers = '23456789';
  static const String _allChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static final Random _random = Random();

  /// Generates a clean, readable 6-character code consisting of both
  /// letters and numbers (e.g. "K9X2B7", "7P4M8K").
  static String generate([int length = 6]) {
    final chars = <String>[];
    // Guarantee at least one letter and at least one number
    chars.add(_letters[_random.nextInt(_letters.length)]);
    chars.add(_numbers[_random.nextInt(_numbers.length)]);

    for (int i = 2; i < length; i++) {
      chars.add(_allChars[_random.nextInt(_allChars.length)]);
    }

    chars.shuffle(_random);
    return chars.join();
  }

  /// Cleans, parses, and extracts a valid room code from direct text,
  /// full URLs (e.g. `http://.../?room=K9X2B7`), or chat invite messages.
  static String cleanCode(String input) {
    String text = input.trim();
    if (text.isEmpty) return '';

    // 1. If a full URL is pasted (e.g. http://192.168.1.3:3000/?room=K9X2B7)
    final uri = Uri.tryParse(text);
    if (uri != null && uri.queryParameters.containsKey('room')) {
      final codeParam = uri.queryParameters['room'];
      if (codeParam != null && codeParam.trim().isNotEmpty) {
        return codeParam.trim().replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '').toUpperCase();
      }
    }

    // 2. Look for explicit prefix like "room code: XXX", "code: XXX", "room: XXX", "code = XXX"
    final explicitMatch = RegExp(
      r'(?:room\s*code|code|room)\s*[:=]\s*([A-Za-z0-9_-]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (explicitMatch != null && explicitMatch.group(1) != null) {
      return explicitMatch.group(1)!.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '').toUpperCase();
    }

    // 3. If text contains spaces/sentences, look for standalone 4-8 character alphanumeric token
    if (text.contains(' ')) {
      final tokenMatch = RegExp(r'\b[A-Za-z0-9]{4,8}\b').firstMatch(text);
      if (tokenMatch != null) {
        return tokenMatch.group(0)!.toUpperCase();
      }
    }

    // 4. Single token or plain code
    return text.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '').toUpperCase();
  }
}
