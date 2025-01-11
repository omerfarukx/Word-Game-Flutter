import 'package:flutter/material.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  border: Border.all(
                    color: _getBorderColor(isFound, isSelected, isHint),
                    width: isFound || isSelected || isHint ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentGrid[row][col],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getCellColor(
      BuildContext context, bool isFound, bool isSelected, bool isHint) {
    if (isFound) return Colors.green.withOpacity(0.8);
    if (isSelected) return Colors.amber.withOpacity(0.8);
    if (isHint) return Colors.yellow.withOpacity(0.3);
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[50]!;
  }

  Color _getBorderColor(bool isFound, bool isSelected, bool isHint) {
    if (isFound) return Colors.green[700]!;
    if (isSelected) return Colors.amber[700]!;
    if (isHint) return Colors.yellow[700]!;
    return Colors.grey[400]!;
  }
}
