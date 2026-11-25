import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/data/f1_word_dictionary.dart';

void main() {
  test('contains 200 unique uppercase alphabetic F1 words', () {
    final wordPattern = RegExp(r'^[A-Z]+$');

    expect(f1Words, hasLength(200));
    expect(f1Words.toSet().length, f1Words.length);
    expect(f1Words, everyElement(matches(wordPattern)));
  });
}
