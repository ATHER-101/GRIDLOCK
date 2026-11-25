import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:word_hunt_f1/models/game_result.dart';
import 'package:word_hunt_f1/screens/result_screen.dart';

void main() {
  testWidgets('shows completed round data and starts the next round', (
    tester,
  ) async {
    var nextRoundPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          result: GameResult(
            roundNumber: 3,
            score: 320,
            wordsFound: 5,
            totalWords: 5,
            completed: true,
          ),
          bestScore: 400,
          onNextRound: () => nextRoundPressed = true,
        ),
      ),
    );

    expect(find.text('ROUND COMPLETE'), findsOneWidget);
    expect(find.text('ROUND 3'), findsOneWidget);
    expect(find.text('320'), findsOneWidget);
    expect(find.text('5 / 5'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);

    await tester.tap(find.text('NEXT ROUND'));
    expect(nextRoundPressed, isTrue);
  });

  testWidgets('shows a loss state and lets the player start a new race', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          result: GameResult(
            roundNumber: 2,
            score: 90,
            wordsFound: 2,
            totalWords: 5,
            completed: false,
          ),
          bestScore: 120,
          onNextRound: () {},
        ),
      ),
    );

    expect(find.text('ROUND FAILED'), findsOneWidget);
    expect(find.text('START AGAIN'), findsOneWidget);
  });
}
