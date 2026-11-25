/// Difficulty settings for a generated word-search round.
class RoundConfig {
  const RoundConfig({
    required this.gridSize,
    required this.wordCount,
    required this.timeLimitSeconds,
    required this.maxIncorrectSwipes,
  });

  final int gridSize;
  final int wordCount;
  final int timeLimitSeconds;
  final int maxIncorrectSwipes;

  /// Returns the progressively harder board configuration for [roundNumber].
  factory RoundConfig.forRound(int roundNumber) {
    if (roundNumber < 1) {
      throw ArgumentError.value(
        roundNumber,
        'roundNumber',
        'Must be at least one.',
      );
    }
    if (roundNumber <= 5) {
      return const RoundConfig(
        gridSize: 6,
        wordCount: 5,
        timeLimitSeconds: 120,
        maxIncorrectSwipes: 3,
      );
    }
    if (roundNumber <= 10) {
      return const RoundConfig(
        gridSize: 7,
        wordCount: 6,
        timeLimitSeconds: 90,
        maxIncorrectSwipes: 3,
      );
    }
    return const RoundConfig(
      gridSize: 8,
      wordCount: 7,
      timeLimitSeconds: 60,
      maxIncorrectSwipes: 2,
    );
  }
}
