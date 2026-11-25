import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/models/puzzle.dart';
import 'package:word_hunt_f1/services/puzzle_generator.dart';

void main() {
  const dictionary = <String>[
    'RACE',
    'GRID',
    'TYRE',
    'DRS',
    'APEX',
    'WING',
    'LAP',
    'POLE',
  ];

  group('PuzzleGenerator', () {
    test('generates a puzzle with the requested dimensions', () {
      final puzzle = PuzzleGenerator(random: Random(1)).generate(
        gridSize: 6,
        wordCount: 5,
        dictionary: dictionary,
      );

      expect(puzzle.grid, hasLength(6));
      expect(puzzle.grid.every((row) => row.length == 6), isTrue);
      expect(puzzle.targetWords, hasLength(5));
    });

    test('places every selected target word in the returned grid', () {
      final puzzle = PuzzleGenerator(random: Random(2)).generate(
        gridSize: 6,
        wordCount: 5,
        dictionary: dictionary,
      );

      for (final word in puzzle.targetWords) {
        expect(_containsWord(puzzle, word), isTrue, reason: '$word is missing');
      }
    });

    test('supports matching-letter overlaps without corrupting either word',
        () {
      final puzzle = PuzzleGenerator(random: Random(3)).generate(
        gridSize: 4,
        wordCount: 2,
        dictionary: const ['RACE', 'ACE'],
      );

      expect(_containsWord(puzzle, 'RACE'), isTrue);
      expect(_containsWord(puzzle, 'ACE'), isTrue);
    });

    test('does not overwrite conflicting letters while placing words', () {
      final puzzle = PuzzleGenerator(random: Random(4)).generate(
        gridSize: 3,
        wordCount: 2,
        dictionary: const ['ABC', 'DEF'],
      );

      expect(_containsWord(puzzle, 'ABC'), isTrue);
      expect(_containsWord(puzzle, 'DEF'), isTrue);
    });

    test('handles impossible input without looping forever', () {
      expect(
        () => PuzzleGenerator(random: Random(5)).generate(
          gridSize: 3,
          wordCount: 1,
          dictionary: const ['VERSTAPPEN'],
        ),
        throwsArgumentError,
      );
    });

    test('different seeds can create different grids', () {
      final first = PuzzleGenerator(random: Random(10)).generate(
        gridSize: 6,
        wordCount: 5,
        dictionary: dictionary,
      );
      final second = PuzzleGenerator(random: Random(20)).generate(
        gridSize: 6,
        wordCount: 5,
        dictionary: dictionary,
      );

      expect(first.grid, isNot(equals(second.grid)));
    });
  });
}

bool _containsWord(Puzzle puzzle, String word) {
  const directions = <List<int>>[
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1],
  ];

  for (var row = 0; row < puzzle.grid.length; row++) {
    for (var column = 0; column < puzzle.grid.length; column++) {
      for (final direction in directions) {
        if (_matchesAt(puzzle.grid, word, row, column, direction)) {
          return true;
        }
      }
    }
  }
  return false;
}

bool _matchesAt(
  List<List<String>> grid,
  String word,
  int startRow,
  int startColumn,
  List<int> direction,
) {
  for (var index = 0; index < word.length; index++) {
    final row = startRow + direction[0] * index;
    final column = startColumn + direction[1] * index;
    if (row < 0 || row >= grid.length || column < 0 || column >= grid.length) {
      return false;
    }
    if (grid[row][column] != word[index]) {
      return false;
    }
  }
  return true;
}
