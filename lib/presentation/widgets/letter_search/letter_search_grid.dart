import 'package:flutter/material.dart';
import 'dart:ui';

class LetterSearchGrid extends StatelessWidget {
  final List<List<String>> currentGrid;
  final List<List<bool>> selectedCells;
  final List<List<bool>> foundCells;
  final List<List<bool>> hintPositions;
  final Function(int, int) onCellTap;

  const LetterSearchGrid({
    super.key,
    required this.currentGrid,
    required this.selectedCells,
    required this.foundCells,
    required this.hintPositions,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ekranın genişliğine göre hücre boyutunu hesapla
        final cellSize =
            (constraints.maxWidth - 32) / 10; // 32 = padding (16 * 2)

        return Container(
          padding: const EdgeInsets.all(16),
          width: constraints.maxWidth,
          height: cellSize * 10 + 32, // Grid yüksekliği + padding
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 100,
            itemBuilder: (context, index) {
              final row = index ~/ 10;
              final col = index % 10;
              final isSelected = selectedCells[row][col];
              final isFound = foundCells[row][col];
              final isHint = hintPositions[row][col];

              return GestureDetector(
                onTap: () => onCellTap(row, col),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getCellColor(context, isFound, isSelected, isHint),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _getShadowColor(
                                context, isFound, isSelected, isHint)
                            .withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color:
                          _getBorderColor(context, isFound, isSelected, isHint),
                      width: isFound || isSelected || isHint ? 2.5 : 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getOverlayColor(
                              context, isFound, isSelected, isHint),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                currentGrid[row][col],
                                style: TextStyle(
                                  fontSize: cellSize *
                                      0.5, // Hücre boyutuna göre yazı boyutu
                                  fontWeight: isFound || isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: _getTextColor(
                                      context, isFound, isSelected, isHint),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getCellColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isFound) {
      return isDark ? const Color(0xFF2E7D32) : const Color(0xFF81C784);
    }
    if (isSelected) {
      return isDark ? const Color(0xFFFFA000) : const Color(0xFFFFD54F);
    }
    if (isHint) {
      return isDark ? const Color(0xFF607D8B) : const Color(0xFFB0BEC5);
    }
    return isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);
  }

  Color _getBorderColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isFound) {
      return isDark ? const Color(0xFF1B5E20) : const Color(0xFF4CAF50);
    }
    if (isSelected) {
      return isDark ? const Color(0xFFFF6F00) : const Color(0xFFFFC107);
    }
    if (isHint) {
      return isDark ? const Color(0xFF455A64) : const Color(0xFF90A4AE);
    }
    return isDark ? const Color(0xFF616161) : const Color(0xFFBDBDBD);
  }

  Color _getShadowColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    if (isFound) return Colors.green[700]!;
    if (isSelected) return Colors.amber[700]!;
    if (isHint) return Colors.blueGrey[700]!;
    return Colors.grey[700]!;
  }

  Color _getOverlayColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isFound) {
      return isDark
          ? Colors.green.withOpacity(0.2)
          : Colors.green.withOpacity(0.1);
    }
    if (isSelected) {
      return isDark
          ? Colors.amber.withOpacity(0.2)
          : Colors.amber.withOpacity(0.1);
    }
    if (isHint) {
      return isDark
          ? Colors.blueGrey.withOpacity(0.2)
          : Colors.blueGrey.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getTextColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isFound) {
      return isDark ? Colors.white : Colors.green[900]!;
    }
    if (isSelected) {
      return isDark ? Colors.white : Colors.amber[900]!;
    }
    if (isHint) {
      return isDark ? Colors.white : Colors.blueGrey[900]!;
    }
    return isDark ? Colors.white : Colors.grey[900]!;
  }
}
