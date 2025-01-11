import 'dart:math';
import 'package:flutter/material.dart';
import '../models/eye_focus_exercise.dart';

class SchultzTable extends StatefulWidget {
  final EyeFocusExercise exercise;
  final Function(int) onNumberFound;
  final VoidCallback onCompleted;

  const SchultzTable({
    Key? key,
    required this.exercise,
    required this.onNumberFound,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<SchultzTable> createState() => _SchultzTableState();
}

class _SchultzTableState extends State<SchultzTable> {
  late List<int> numbers;
  int currentNumber = 1;
  Set<int> foundNumbers = {};

  @override
  void initState() {
    super.initState();
    _initializeNumbers();
  }

  void _initializeNumbers() {
    final totalNumbers = widget.exercise.gridSize * widget.exercise.gridSize;
    numbers = List.generate(totalNumbers, (index) => index + 1);
    if (widget.exercise.settings['randomize'] == true) {
      numbers.shuffle(Random());
    }
  }

  void _handleNumberTap(int number) {
    if (number == currentNumber) {
      setState(() {
        foundNumbers.add(number);
        currentNumber++;
      });
      widget.onNumberFound(number);

      if (currentNumber > numbers.length) {
        widget.onCompleted();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / widget.exercise.gridSize;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.exercise.gridSize,
            ),
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              final number = numbers[index];
              final isFound = foundNumbers.contains(number);
              final isNext = number == currentNumber;

              return GestureDetector(
                onTap: () => _handleNumberTap(number),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isFound
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : isNext
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isNext
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.2),
                      width: isNext ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: cellSize * 0.4,
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.normal,
                        color: isFound
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
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
}
