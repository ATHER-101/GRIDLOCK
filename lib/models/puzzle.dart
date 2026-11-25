import 'dart:collection';

/// A generated word-search board and the words hidden in it.
class Puzzle {
  Puzzle({
    required List<List<String>> grid,
    required List<String> targetWords,
    required this.roundNumber,
    Iterable<String> foundWords = const <String>[],
  })  : grid = _freezeGrid(grid),
        targetWords = List.unmodifiable(_validateWords(targetWords)),
        foundWords = Set.unmodifiable(_validateFoundWords(foundWords)) {
    if (roundNumber < 1) {
      throw ArgumentError.value(
        roundNumber,
        'roundNumber',
        'Round number must be at least one.',
      );
    }
    if (!this.foundWords.every(this.targetWords.contains)) {
      throw ArgumentError.value(
        foundWords,
        'foundWords',
        'Found words must be target words.',
      );
    }
  }

  final List<List<String>> grid;
  final List<String> targetWords;
  final int roundNumber;
  final Set<String> foundWords;

  static List<List<String>> _freezeGrid(List<List<String>> input) {
    if (input.isEmpty || input.any((row) => row.isEmpty)) {
      throw ArgumentError.value(input, 'grid', 'Grid cannot be empty.');
    }
    final width = input.first.length;
    if (input.any((row) => row.length != width)) {
      throw ArgumentError.value(
          input, 'grid', 'Grid rows must be equal length.');
    }
    for (final row in input) {
      for (final letter in row) {
        if (!RegExp(r'^[A-Z]$').hasMatch(letter)) {
          throw ArgumentError.value(
            letter,
            'grid',
            'Grid cells must contain uppercase A-Z letters.',
          );
        }
      }
    }
    return UnmodifiableListView<List<String>>(
      input.map((row) => List.unmodifiable(row)),
    );
  }

  static List<String> _validateWords(List<String> input) {
    if (input.isEmpty) {
      throw ArgumentError.value(
          input, 'targetWords', 'At least one target word is required.');
    }
    if (input.any((word) => !RegExp(r'^[A-Z]+$').hasMatch(word))) {
      throw ArgumentError.value(
        input,
        'targetWords',
        'Target words must contain only uppercase A-Z letters.',
      );
    }
    if (input.toSet().length != input.length) {
      throw ArgumentError.value(
          input, 'targetWords', 'Target words must be unique.');
    }
    return input;
  }

  static Set<String> _validateFoundWords(Iterable<String> input) {
    final words = input.toSet();
    if (words.any((word) => !RegExp(r'^[A-Z]+$').hasMatch(word))) {
      throw ArgumentError.value(
        input,
        'foundWords',
        'Found words must contain only uppercase A-Z letters.',
      );
    }
    return words;
  }
}
