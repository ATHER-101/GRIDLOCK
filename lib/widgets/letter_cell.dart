import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// One visual letter tile in a [LetterGrid].
class LetterCell extends StatelessWidget {
  const LetterCell({
    super.key,
    required this.row,
    required this.column,
    required this.letter,
    required this.isSelected,
    required this.isFound,
    this.onTap,
  });

  final int row;
  final int column;
  final String letter;
  final bool isSelected;
  final bool isFound;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isSelected || isFound ? AppColors.white : AppColors.white;
    final background = isSelected
        ? AppColors.racingRed
        : isFound
            ? const Color(0xFF137A45)
            : AppColors.surface;
    final stateLabel = isSelected
        ? 'selected'
        : isFound
            ? 'found'
            : 'unselected';

    return Semantics(
      button: onTap != null,
      label:
          'Letter $letter, row ${row + 1}, column ${column + 1}, $stateLabel',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.white
                    : isFound
                        ? const Color(0xFF5BE394)
                        : AppColors.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.racingRed.withValues(alpha: .38),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
