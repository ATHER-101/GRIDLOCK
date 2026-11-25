import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/models/game_result.dart';
import 'package:word_hunt_f1/models/grid_cell.dart';
import 'package:word_hunt_f1/models/puzzle.dart';

void main() {
  group('GridCell', () {
    test('accepts a valid uppercase grid location', () {
      final cell = GridCell(row: 2, column: 3, letter: 'F');

      expect(cell.row, 2);
      expect(cell.column, 3);
      expect(cell.letter, 'F');
    });

    test('rejects invalid coordinates and letters', () {
      expect(
        () => GridCell(row: -1, column: 0, letter: 'A'),
        throwsArgumentError,
      );
      expect(
        () => GridCell(row: 0, column: 0, letter: 'ab'),
        throwsArgumentError,
      );
    });
  });

  group('Puzzle', () {
    test('stores immutable puzzle data', () {
      final puzzle = Puzzle(
        grid: const [
          ['R', 'A'],
          ['C', 'E'],
        ],
        targetWords: const ['RACE'],
        foundWords: const ['RACE'],
        roundNumber: 1,
      );

      expect(puzzle.grid[0][0], 'R');
      expect(puzzle.targetWords, ['RACE']);
      expect(puzzle.foundWords, {'RACE'});
      expect(() => puzzle.grid[0][0] = 'X', throwsUnsupportedError);
    });

    test('rejects malformed grids and found non-target words', () {
      expect(
        () => Puzzle(
          grid: const [
            ['A'],
            ['B', 'C'],
          ],
          targetWords: const ['ABC'],
          roundNumber: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => Puzzle(
          grid: const [
            ['A'],
          ],
          targetWords: const ['A'],
          foundWords: const ['B'],
          roundNumber: 1,
        ),
        throwsArgumentError,
      );
    });
  });

  group('GameResult', () {
    test('accepts a valid completed result', () {
      final result = GameResult(
        roundNumber: 1,
        score: 250,
        wordsFound: 5,
        totalWords: 5,
        completed: true,
      );

      expect(result.score, 250);
      expect(result.completed, isTrue);
    });

    test('rejects impossible completion states', () {
      expect(
        () => GameResult(
          roundNumber: 1,
          score: 0,
          wordsFound: 2,
          totalWords: 3,
          completed: true,
        ),
        throwsArgumentError,
      );
    });
  });
}
