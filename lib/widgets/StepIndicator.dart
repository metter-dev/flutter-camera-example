import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int pageIndex; // The current step index

  const StepIndicator({Key? key, required this.pageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final bool isCompleted =
              index < pageIndex; // Steps before the current step
          final bool isCurrent = index == pageIndex; // Current step

          return Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : (isCurrent ? Colors.green : Colors.grey[300]),
                  border: Border.all(
                    color: isCompleted || isCurrent
                        ? Colors.green
                        : Colors.grey[300]!,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < 4) // Only add a connector if not the last step
                Container(
                  width: 20,
                  height: 2,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }
}
