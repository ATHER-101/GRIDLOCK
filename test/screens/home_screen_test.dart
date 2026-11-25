import 'package:flutter_test/flutter_test.dart';
import 'package:word_hunt_f1/main.dart';

void main() {
  testWidgets('shows branding, best score, and sound control', (tester) async {
    await tester.pumpWidget(const WordHuntF1App());

    expect(find.text('GRIDLOCK'), findsOneWidget);
    expect(find.text('PERSONAL BEST'), findsOneWidget);
    expect(find.text('PLAY GRID'), findsOneWidget);
    expect(find.byTooltip('Sound on'), findsOneWidget);

    await tester.tap(find.byTooltip('Sound on'));
    await tester.pump();

    expect(find.byTooltip('Sound off'), findsOneWidget);
  });

  testWidgets('opens the game screen from Play Grid', (tester) async {
    await tester.pumpWidget(const WordHuntF1App());

    await tester.tap(find.text('PLAY GRID'));
    await tester.pumpAndSettle();

    expect(find.text('THE GRID'), findsOneWidget);
    expect(find.text('SWIPE THE GRID'), findsOneWidget);
  });
}
