/// Validates a completed swipe against the current puzzle state.
class WordValidator {
  const WordValidator();

  /// Returns true only when [selectedWord] matches an unfound target word.
  ///
  /// Swiping a target from either end is valid. Comparisons are deliberately
  /// case-insensitive so UI input and stored puzzle data cannot drift apart.
  bool isValidWord({
    required String selectedWord,
    required List<String> targetWords,
    required Set<String> foundWords,
  }) {
    final selection = _normalize(selectedWord);
    if (selection.isEmpty) {
      return false;
    }

    final found = foundWords.map(_normalize).toSet();
    final reversedSelection = selection.split('').reversed.join();

    for (final targetWord in targetWords) {
      final target = _normalize(targetWord);
      if ((target == selection || target == reversedSelection) &&
          !found.contains(target)) {
        return true;
      }
    }
    return false;
  }

  String _normalize(String value) => value.trim().toUpperCase();
}
