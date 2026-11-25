import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/models/grid_cell.dart';
import 'package:word_hunt_f1/services/game_session.dart';
import 'package:word_hunt_f1/services/puzzle_generator.dart';

void main() {
  GameSession createSession({int bestScore = 0}) => GameSession(
        puzzleGenerator: PuzzleGenerator(random: Random(1)),
        dictionary: const ['DRS', 'RACE', 'TYRE', 'WING', 'LAP'],
        wordCount: 5,
        bestScore: bestScore,
      );

  List<GridCell> cellsFor(GameSession session, String word) => List.generate(
        word.length,
        (index) => GridCell(row: 0, column: index, letter: word[index]),
      );

  group('GameSession scoring', () {
    test('uses the defined point tiers', () {
      expect(GameSession.scoreForWord('DRS'), 30);
      expect(GameSession.scoreForWord('RACE'), 40);
      expect(GameSession.scoreForWord('TYREX'), 50);
      expect(GameSession.scoreForWord('FORMULA'), 60);
    });

    test('marks a valid target found and updates score and best score', () {
      final session = createSession();
      final target = session.puzzle.targetWords.first;

      final result = session.submitSelection(cellsFor(session, target));

      expect(result, SelectionResult.found);
      expect(session.foundWords, contains(target));
      expect(session.currentScore, GameSession.scoreForWord(target));
      expect(session.bestScore, session.currentScore);
    });

    test('rejects duplicate and unknown selections without scoring', () {
      final session = createSession();
      final target = session.puzzle.targetWords.first;
      session.submitSelection(cellsFor(session, target));
      final score = session.currentScore;

      expect(session.submitSelection(cellsFor(session, target)),
          SelectionResult.duplicate);
      expect(
        session.submitSelection([
          GridCell(row: 0, column: 0, letter: 'X'),
          GridCell(row: 0, column: 1, letter: 'Y'),
        ]),
        SelectionResult.invalid,
      );
      expect(session.currentScore, score);
    });

    test('awards the completion bonus exactly once on the final word', () {
      final session = createSession(bestScore: 999);
      for (final target in session.puzzle.targetWords) {
        final result = session.submitSelection(cellsFor(session, target));
        if (target == session.puzzle.targetWords.last) {
          expect(result, SelectionResult.roundCompleted);
        } else {
          expect(result, SelectionResult.found);
        }
      }

      final expectedScore = session.puzzle.targetWords
              .map(GameSession.scoreForWord)
              .reduce((sum, points) => sum + points) +
          GameSession.roundCompletionBonus;
      expect(session.currentScore, expectedScore);
      expect(session.bestScore, 999);
      expect(session.isComplete, isTrue);
    });
  });
}
