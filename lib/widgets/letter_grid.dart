import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/grid_cell.dart';
import 'letter_cell.dart';

/// A square, responsive visual board for a generated word-search puzzle.
class LetterGrid extends StatefulWidget {
  const LetterGrid({
    super.key,
    required this.grid,
    this.selectedCells = const <GridCell>{},
    this.foundCells = const <GridCell>{},
    this.onCellTap,
    this.onSelectionChanged,
    this.onSelectionCompleted,
  });

  final List<List<String>> grid;
  final Set<GridCell> selectedCells;
  final Set<GridCell> foundCells;
  final ValueChanged<GridCell>? onCellTap;
  final ValueChanged<List<GridCell>>? onSelectionChanged;
  final ValueChanged<List<GridCell>>? onSelectionCompleted;

  @override
  State<LetterGrid> createState() => _LetterGridState();
}

class _LetterGridState extends State<LetterGrid> {
  final GlobalKey _boardKey = GlobalKey();
  List<GridCell> _dragSelection = const <GridCell>[];

  @override
  Widget build(BuildContext context) {
    final grid = widget.grid;
    if (grid.isEmpty || grid.any((row) => row.length != grid.length)) {
      throw ArgumentError.value(
        grid,
        'grid',
        'LetterGrid requires a non-empty square grid.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = math.min(constraints.maxWidth, 520.0);
        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Listener(
            key: _boardKey,
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _beginSelection(event.position),
            onPointerMove: (event) => _extendSelection(event.position),
            onPointerUp: (_) => _completeSelection(),
            onPointerCancel: (_) => _completeSelection(),
            child: GridView.builder(
              key: const Key('letter-grid'),
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: grid.length,
                crossAxisSpacing: _spacingFor(grid.length),
                mainAxisSpacing: _spacingFor(grid.length),
              ),
              itemCount: grid.length * grid.length,
              itemBuilder: (context, index) {
                final row = index ~/ grid.length;
                final column = index % grid.length;
                final cell = GridCell(
                  row: row,
                  column: column,
                  letter: grid[row][column],
                );
                return LetterCell(
                  key: Key('letter-cell-$row-$column'),
                  row: row,
                  column: column,
                  letter: cell.letter,
                  isSelected: widget.selectedCells.contains(cell) ||
                      _dragSelection.contains(cell),
                  isFound: widget.foundCells.contains(cell),
                  onTap: widget.onCellTap == null
                      ? null
                      : () => widget.onCellTap!(cell),
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _spacingFor(int gridSize) => gridSize >= 8 ? 4 : 6;

  void _beginSelection(Offset globalPosition) {
    final cell = _cellAtGlobalPosition(globalPosition);
    if (cell == null) {
      return;
    }
    _setSelection([cell]);
  }

  void _extendSelection(Offset globalPosition) {
    if (_dragSelection.isEmpty) {
      return;
    }
    final endCell = _cellAtGlobalPosition(globalPosition);
    if (endCell == null) {
      return;
    }
    final startCell = _dragSelection.first;
    final rowDelta = endCell.row - startCell.row;
    final columnDelta = endCell.column - startCell.column;
    final isStraightLine = rowDelta == 0 ||
        columnDelta == 0 ||
        rowDelta.abs() == columnDelta.abs();
    if (!isStraightLine) {
      return;
    }

    final previousDirection = _directionFor(_dragSelection);
    final currentDirection = _Direction(
      _unitDirection(rowDelta),
      _unitDirection(columnDelta),
    );
    if (previousDirection != null && currentDirection != previousDirection) {
      return;
    }

    final length = math.max(rowDelta.abs(), columnDelta.abs());
    final selection = List<GridCell>.generate(
      length + 1,
      (index) => GridCell(
        row: startCell.row + currentDirection.rowDelta * index,
        column: startCell.column + currentDirection.columnDelta * index,
        letter: widget.grid[startCell.row + currentDirection.rowDelta * index]
            [startCell.column + currentDirection.columnDelta * index],
      ),
    );
    _setSelection(selection);
  }

  _Direction? _directionFor(List<GridCell> selection) {
    if (selection.length < 2) {
      return null;
    }
    final start = selection.first;
    final next = selection[1];
    return _Direction(next.row - start.row, next.column - start.column);
  }

  int _unitDirection(int delta) => delta == 0
      ? 0
      : delta.isNegative
          ? -1
          : 1;

  GridCell? _cellAtGlobalPosition(Offset globalPosition) {
    final renderBox =
        _boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    }
    final localPosition = renderBox.globalToLocal(globalPosition);
    final boardSize = renderBox.size.width;
    if (localPosition.dx < 0 ||
        localPosition.dy < 0 ||
        localPosition.dx >= boardSize ||
        localPosition.dy >= boardSize) {
      return null;
    }
    final spacing = _spacingFor(widget.grid.length);
    final cellSize =
        (boardSize - spacing * (widget.grid.length - 1)) / widget.grid.length;
    final stride = cellSize + spacing;
    final row = (localPosition.dy / stride).floor();
    final column = (localPosition.dx / stride).floor();
    if (row >= widget.grid.length || column >= widget.grid.length) {
      return null;
    }
    if (localPosition.dy - row * stride > cellSize ||
        localPosition.dx - column * stride > cellSize) {
      return null;
    }
    return GridCell(row: row, column: column, letter: widget.grid[row][column]);
  }

  void _setSelection(List<GridCell> selection) {
    setState(() => _dragSelection = List.unmodifiable(selection));
    widget.onSelectionChanged?.call(_dragSelection);
  }

  void _completeSelection() {
    final completedSelection = List<GridCell>.from(_dragSelection);
    if (completedSelection.length > 1) {
      widget.onSelectionCompleted?.call(completedSelection);
    }
    if (_dragSelection.isNotEmpty) {
      setState(() => _dragSelection = const <GridCell>[]);
      widget.onSelectionChanged?.call(const <GridCell>[]);
    }
  }
}

class _Direction {
  const _Direction(this.rowDelta, this.columnDelta);

  final int rowDelta;
  final int columnDelta;

  @override
  bool operator ==(Object other) =>
      other is _Direction &&
      rowDelta == other.rowDelta &&
      columnDelta == other.columnDelta;

  @override
  int get hashCode => Object.hash(rowDelta, columnDelta);
}
