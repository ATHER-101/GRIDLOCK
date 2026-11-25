import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/services/word_validator.dart';

void main() {
  const validator = WordValidator();
  const targets = ['RACE', 'GRID', 'DRS'];

  group('WordValidator', () {
    test('accepts an unfound target in its forward direction', () {
      expect(
        validator.isValidWord(
          selectedWord: 'RACE',
          targetWords: targets,
          foundWords: const {},
        ),
        isTrue,
      );
    });

    test('accepts an unfound target in reverse direction', () {
      expect(
        validator.isValidWord(
          selectedWord: 'ECAR',
          targetWords: targets,
          foundWords: const {},
        ),
        isTrue,
      );
    });

    test('compares selected and stored words without regard to case', () {
      expect(
        validator.isValidWord(
          selectedWord: 'grid',
          targetWords: const ['rAcE', 'gRiD'],
          foundWords: const {},
        ),
        isTrue,
      );
    });

    test('rejects a word that is not a target', () {
      expect(
        validator.isValidWord(
          selectedWord: 'TYRE',
          targetWords: targets,
          foundWords: const {},
        ),
        isFalse,
      );
    });

    test('rejects a target that has already been found', () {
      expect(
        validator.isValidWord(
          selectedWord: 'ECAR',
          targetWords: targets,
          foundWords: const {'race'},
        ),
        isFalse,
      );
    });

    test('rejects an empty selection', () {
      expect(
        validator.isValidWord(
          selectedWord: '   ',
          targetWords: targets,
          foundWords: const {},
        ),
        isFalse,
      );
    });
  });
}
