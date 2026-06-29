/// Turkish-aware text helpers.
///
/// Dart's default `toLowerCase`/`toUpperCase` are locale-insensitive and
/// mishandle the dotted/dotless I pair (İ/I ↔ i/ı). Every word comparison in
/// the games goes through here so "İSTANBUL" lowercases to "istanbul" and
/// "ışık" uppercases to "IŞIK" correctly.
class Tr {
  const Tr._();

  static String lower(String input) =>
      input.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

  static String upper(String input) =>
      input.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

  /// Last letter of a word, lowercased. (Turkish letters are single UTF-16
  /// code units, so plain indexing is safe here.)
  static String lastLetter(String input) {
    final w = lower(input.trim());
    return w.isEmpty ? '' : w.substring(w.length - 1);
  }

  /// First letter of a word, lowercased.
  static String firstLetter(String input) {
    final w = lower(input.trim());
    return w.isEmpty ? '' : w.substring(0, 1);
  }

  /// Only Turkish letters, nothing else (no digits, spaces, punctuation).
  static final RegExp lettersOnly = RegExp(r'^[a-zçğıöşü]+$');
}
