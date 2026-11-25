import '../models/grid_cell.dart';
import '../models/puzzle.dart';
import 'puzzle_generator.dart';
import 'word_validator.dart';

/// The in-memory state for one puzzle round.
///
/// Keeping scoring and selection results here makes the game rules testable
/// without a widget test. Persistence and round progression are deliberately
/// left to their later milestones.
class GameSession {
  GameSession({
    required PuzzleGenerator puzzleGenerator,
    required List<String> dictionary,
    this.currentRound = 1,
    this.currentScore = 0,
    this.bestScore = 0,
    this.gridSize = 6,
    this.wordCount = 5,
    WordValidator wordValidator = const WordValidator(),
  })  : _wordValidator = wordValidator,
        puzzle = puzzleGenerator.generate(
          gridSize: gridSize,
          wordCount: wordCount,
          dictionary: dictionary,
          roundNumber: currentRound,
        ) {
    if (currentScore < 0 || bestScore < 0) {
      throw ArgumentError('Scores cannot be negative.');
    }
  }

  final WordValidator _wordValidator;
  final Puzzle puzzle;
  final int gridSize;
  final int wordCount;
  final int currentRound;
  int currentScore;
  int bestScore;
  final Set<String> foundWords = <String>{};
  final Set<GridCell> foundCells = <GridCell>{};

  bool get isComplete => foundWords.length == puzzle.targetWords.length;

  /// Applies a completed straight-line swipe and returns the outcome.
  SelectionResult submitSelection(List<GridCell> cells) {
    final selectedWord = cells.map((cell) => cell.letter).join();
    final matchedWord = matchingTarget(selectedWord);

    if (!_wordValidator.isValidWord(
      selectedWord: selectedWord,
      targetWords: puzzle.targetWords,
      foundWords: foundWords,
    )) {
      return matchedWord == null
          ? SelectionResult.invalid
          : SelectionResult.duplicate;
    }

    // A valid selection always has a matching puzzle target.
    foundWords.add(matchedWord!);
    foundCells.addAll(cells);
    currentScore += scoreForWord(matchedWord);

    if (isComplete) {
      currentScore += roundCompletionBonus;
      bestScore = currentScore > bestScore ? currentScore : bestScore;
      return SelectionResult.roundCompleted;
    }

    bestScore = currentScore > bestScore ? currentScore : bestScore;
    return SelectionResult.found;
  }

  String? matchingTarget(String selectedWord) {
    final normalized = selectedWord.trim().toUpperCase();
    final reversed = normalized.split('').reversed.join();
    for (final target in puzzle.targetWords) {
      if (target == normalized || target == reversed) {
        return target;
      }
    }
    return null;
  }

  static const int roundCompletionBonus = 100;

  static int scoreForWord(String word) {
    switch (word.length) {
      case 0:
      case 1:
      case 2:
        return 0;
      case 3:
        return 30;
      case 4:
        return 40;
      case 5:
        return 50;
      default:
        return 60;
    }
  }
}

enum SelectionResult { found, duplicate, invalid, roundCompleted }
