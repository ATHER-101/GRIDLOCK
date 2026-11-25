import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/services/round_config.dart';

void main() {
  group('RoundConfig', () {
    test('uses the 6 by 6 configuration for rounds one through five', () {
      for (final round in [1, 5]) {
        final config = RoundConfig.forRound(round);
        expect(config.gridSize, 6);
        expect(config.wordCount, 5);
        expect(config.timeLimitSeconds, 120);
        expect(config.maxIncorrectSwipes, 3);
      }
    });

    test('uses the 7 by 7 configuration for rounds six through ten', () {
      for (final round in [6, 10]) {
        final config = RoundConfig.forRound(round);
        expect(config.gridSize, 7);
        expect(config.wordCount, 6);
        expect(config.timeLimitSeconds, 90);
        expect(config.maxIncorrectSwipes, 3);
      }
    });

    test('uses the 8 by 8 configuration from round eleven onwards', () {
      final config = RoundConfig.forRound(11);
      expect(config.gridSize, 8);
      expect(config.wordCount, 7);
      expect(config.timeLimitSeconds, 60);
      expect(config.maxIncorrectSwipes, 2);
    });

    test('rejects a round below one', () {
      expect(() => RoundConfig.forRound(0), throwsArgumentError);
    });
  });
}
