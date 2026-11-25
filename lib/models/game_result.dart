/// The score and completion state for one completed or abandoned round.
class GameResult {
  GameResult({
    required this.roundNumber,
    required this.score,
    required this.wordsFound,
    required this.totalWords,
    required this.completed,
  }) {
    if (roundNumber < 1) {
      throw ArgumentError.value(
          roundNumber, 'roundNumber', 'Must be at least one.');
    }
    if (score < 0) {
      throw ArgumentError.value(score, 'score', 'Cannot be negative.');
    }
    if (totalWords < 0 || wordsFound < 0 || wordsFound > totalWords) {
      throw ArgumentError('Words found must be between zero and total words.');
    }
    if (completed && wordsFound != totalWords) {
      throw ArgumentError('A completed round must have every word found.');
    }
  }

  final int roundNumber;
  final int score;
  final int wordsFound;
  final int totalWords;
  final bool completed;
}
