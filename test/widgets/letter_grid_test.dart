import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:word_hunt_f1/models/grid_cell.dart';
import 'package:word_hunt_f1/widgets/letter_cell.dart';
import 'package:word_hunt_f1/widgets/letter_grid.dart';

void main() {
  const grid = <List<String>>[
    ['R', 'A', 'C'],
    ['E', 'D', 'R'],
    ['S', 'P', 'O'],
  ];

  Widget buildGrid({
    Set<GridCell> selectedCells = const {},
    Set<GridCell> foundCells = const {},
    ValueChanged<GridCell>? onCellTap,
    ValueChanged<List<GridCell>>? onSelectionCompleted,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: LetterGrid(
              grid: grid,
              selectedCells: selectedCells,
              foundCells: foundCells,
              onCellTap: onCellTap,
              onSelectionCompleted: onSelectionCompleted,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders every letter in an equal square grid', (tester) async {
    await tester.pumpWidget(buildGrid());

    expect(find.byType(LetterCell), findsNWidgets(9));
    expect(find.text('R'), findsNWidgets(2));
    expect(find.byKey(const Key('letter-cell-2-2')), findsOneWidget);
  });

  testWidgets('exposes selected and found states independently',
      (tester) async {
    final selected = GridCell(row: 0, column: 0, letter: 'R');
    final found = GridCell(row: 1, column: 1, letter: 'D');
    await tester.pumpWidget(
      buildGrid(selectedCells: {selected}, foundCells: {found}),
    );

    expect(
      tester
          .widget<LetterCell>(find.byKey(const Key('letter-cell-0-0')))
          .isSelected,
      isTrue,
    );
    expect(
      tester
          .widget<LetterCell>(find.byKey(const Key('letter-cell-1-1')))
          .isFound,
      isTrue,
    );
  });

  testWidgets('reports the tapped cell to the board callback', (tester) async {
    GridCell? tappedCell;
    await tester.pumpWidget(buildGrid(onCellTap: (cell) => tappedCell = cell));

    await tester.tap(find.byKey(const Key('letter-cell-0-1')));

    expect(tappedCell, GridCell(row: 0, column: 1, letter: 'A'));
  });

  testWidgets('selects a straight swipe and clears it after completion', (
    tester,
  ) async {
    List<GridCell>? completedSelection;
    await tester.pumpWidget(
      buildGrid(
          onCellTap: (_) {},
          onSelectionCompleted: (cells) {
            completedSelection = cells;
          }),
    );

    final start = tester.getCenter(find.byKey(const Key('letter-cell-0-0')));
    final end = tester.getCenter(find.byKey(const Key('letter-cell-0-2')));
    final gesture = await tester.startGesture(start);
    await gesture.moveTo(end);
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(completedSelection?.map((cell) => cell.letter), ['R', 'A', 'C']);
    expect(
      tester
          .widget<LetterCell>(find.byKey(const Key('letter-cell-0-0')))
          .isSelected,
      isFalse,
    );
  });
}
