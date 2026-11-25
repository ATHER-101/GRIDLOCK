/// A single immutable letter location in a puzzle grid.
class GridCell {
  GridCell({
    required this.row,
    required this.column,
    required String letter,
  }) : letter = _validateLetter(letter) {
    if (row < 0 || column < 0) {
      throw ArgumentError.value(
        row < 0 ? row : column,
        row < 0 ? 'row' : 'column',
        'Grid coordinates must be non-negative.',
      );
    }
  }

  final int row;
  final int column;
  final String letter;

  @override
  bool operator ==(Object other) {
    return other is GridCell &&
        row == other.row &&
        column == other.column &&
        letter == other.letter;
  }

  @override
  int get hashCode => Object.hash(row, column, letter);

  static String _validateLetter(String value) {
    if (!RegExp(r'^[A-Z]$').hasMatch(value)) {
      throw ArgumentError.value(
        value,
        'letter',
        'A grid letter must be exactly one uppercase A-Z character.',
      );
    }
    return value;
  }
}
