import 'dart:math';

import '../models/puzzle.dart';

/// Creates finite, offline word-search puzzles.
class PuzzleGenerator {
  PuzzleGenerator({Random? random, this.maxGenerationAttempts = 30})
      : _random = random ?? Random() {
    if (maxGenerationAttempts < 1) {
      throw ArgumentError.value(
        maxGenerationAttempts,
        'maxGenerationAttempts',
        'Must be at least one.',
      );
    }
  }

  final Random _random;
  final int maxGenerationAttempts;

  /// Generates a square puzzle containing exactly [wordCount] target words.
  ///
  /// [roundNumber] is optional here because the generator is independent from
  /// UI state; game screens can supply their current round when available.
  Puzzle generate({
    required int gridSize,
    required int wordCount,
    required List<String> dictionary,
    int roundNumber = 1,
  }) {
    _validateInput(
      gridSize: gridSize,
      wordCount: wordCount,
      dictionary: dictionary,
      roundNumber: roundNumber,
    );

    final eligibleWords =
        dictionary.toSet().where((word) => word.length <= gridSize).toList();
    if (eligibleWords.length < wordCount) {
      throw ArgumentError.value(
        wordCount,
        'wordCount',
        'Not enough unique dictionary words fit in a $gridSize×$gridSize grid.',
      );
    }

    for (var attempt = 0; attempt < maxGenerationAttempts; attempt++) {
      final grid = List<List<String?>>.generate(
        gridSize,
        (_) => List<String?>.filled(gridSize, null),
      );
      final candidates = List<String>.from(eligibleWords)..shuffle(_random);
      final placedWords = <String>[];

      for (final word in candidates) {
        if (placedWords.length == wordCount) {
          break;
        }
        if (_placeWord(grid, word)) {
          placedWords.add(word);
        }
      }

      if (placedWords.length == wordCount) {
        return Puzzle(
          grid: _fillEmptyCells(grid),
          targetWords: placedWords,
          roundNumber: roundNumber,
        );
      }
    }

    throw StateError(
      'Unable to place $wordCount words in a $gridSize×$gridSize grid after '
      '$maxGenerationAttempts bounded attempts.',
    );
  }

  void _validateInput({
    required int gridSize,
    required int wordCount,
    required List<String> dictionary,
    required int roundNumber,
  }) {
    if (gridSize < 2) {
      throw ArgumentError.value(gridSize, 'gridSize', 'Must be at least two.');
    }
    if (wordCount < 1) {
      throw ArgumentError.value(
          wordCount, 'wordCount', 'Must be at least one.');
    }
    if (roundNumber < 1) {
      throw ArgumentError.value(
        roundNumber,
        'roundNumber',
        'Must be at least one.',
      );
    }
    if (dictionary.any((word) => !RegExp(r'^[A-Z]+$').hasMatch(word))) {
      throw ArgumentError.value(
        dictionary,
        'dictionary',
        'Words must contain only uppercase A-Z letters.',
      );
    }
  }

  bool _placeWord(List<List<String?>> grid, String word) {
    final placements = <_Placement>[];
    var greatestOverlap = -1;

    for (var row = 0; row < grid.length; row++) {
      for (var column = 0; column < grid.length; column++) {
        for (final direction in _directions) {
          final placement = _Placement(
            word: word,
            row: row,
            column: column,
            direction: direction,
          );
          final overlap = _overlapIfValid(grid, placement);
          if (overlap == null) {
            continue;
          }
          if (overlap > greatestOverlap) {
            greatestOverlap = overlap;
            placements
              ..clear()
              ..add(placement);
          } else if (overlap == greatestOverlap) {
            placements.add(placement);
          }
        }
      }
    }

    if (placements.isEmpty) {
      return false;
    }
    final chosen = placements[_random.nextInt(placements.length)];
    for (var index = 0; index < word.length; index++) {
      final row = chosen.row + chosen.direction.rowDelta * index;
      final column = chosen.column + chosen.direction.columnDelta * index;
      grid[row][column] = word[index];
    }
    return true;
  }

  int? _overlapIfValid(List<List<String?>> grid, _Placement placement) {
    var overlap = 0;
    for (var index = 0; index < placement.word.length; index++) {
      final row = placement.row + placement.direction.rowDelta * index;
      final column = placement.column + placement.direction.columnDelta * index;
      if (row < 0 ||
          row >= grid.length ||
          column < 0 ||
          column >= grid.length) {
        return null;
      }
      final existingLetter = grid[row][column];
      final letter = placement.word[index];
      if (existingLetter != null && existingLetter != letter) {
        return null;
      }
      if (existingLetter == letter) {
        overlap++;
      }
    }
    return overlap;
  }

  List<List<String>> _fillEmptyCells(List<List<String?>> grid) {
    return grid
        .map(
          (row) => row
              .map(
                (letter) =>
                    letter ?? String.fromCharCode(65 + _random.nextInt(26)),
              )
              .toList(),
        )
        .toList();
  }
}

class _Placement {
  const _Placement({
    required this.word,
    required this.row,
    required this.column,
    required this.direction,
  });

  final String word;
  final int row;
  final int column;
  final _Direction direction;
}

class _Direction {
  const _Direction(this.rowDelta, this.columnDelta);

  final int rowDelta;
  final int columnDelta;
}

const _directions = <_Direction>[
  _Direction(-1, -1),
  _Direction(-1, 0),
  _Direction(-1, 1),
  _Direction(0, -1),
  _Direction(0, 1),
  _Direction(1, -1),
  _Direction(1, 0),
  _Direction(1, 1),
];
