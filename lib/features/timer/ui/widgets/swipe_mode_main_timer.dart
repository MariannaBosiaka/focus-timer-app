import 'package:flutter/material.dart';

class SwipeModeMainTimer extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;

  const SwipeModeMainTimer({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modes = ["Focus", "Short Break", "Long Break"];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: modes.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedMode;
          return GestureDetector(
            onTap: () => onModeChanged(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                modes[index],
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
