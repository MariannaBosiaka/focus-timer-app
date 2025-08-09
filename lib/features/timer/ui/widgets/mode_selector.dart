import 'package:flutter/material.dart';

class ModeSelector extends StatefulWidget {
  final ValueChanged<int> onModeChanged;

  const ModeSelector({super.key, required this.onModeChanged});

  @override
  State<ModeSelector> createState() => _ModeSelectorState();
}

class _ModeSelectorState extends State<ModeSelector> {
  int _selectedIndex = 0;
  final List<String> _modes = ["Focus", "Short Break", "Long Break"];
  double _dragOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = (MediaQuery.of(context).size.width - 48) / _modes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          final buttonWidth = (MediaQuery.of(context).size.width - 48) / _modes.length;
          final maxOffset = (_modes.length - 1 - _selectedIndex) * buttonWidth;
          final minOffset = -_selectedIndex * buttonWidth;

          setState(() {
            _dragOffset += details.delta.dx;
            _dragOffset = _dragOffset.clamp(minOffset, maxOffset);
          });
        },
        onHorizontalDragEnd: (_) {
          final int draggedIndex = (_dragOffset / buttonWidth).round();
          final newIndex = (_selectedIndex + draggedIndex).clamp(0, _modes.length - 1);

          setState(() {
            _selectedIndex = newIndex;
            _dragOffset = 0;
          });

          widget.onModeChanged(newIndex);
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(-1 + (_selectedIndex * 1.0) + (_dragOffset / buttonWidth), 0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Container(
                  width: buttonWidth,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Row(
                children: List.generate(_modes.length, (index) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        _modes[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedIndex == index
                              ? Colors.black
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
