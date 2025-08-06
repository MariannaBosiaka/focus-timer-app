import 'package:flutter/material.dart';

class SnappingScrollPhysics extends ScrollPhysics {
  final double itemExtent;

  const SnappingScrollPhysics({required this.itemExtent, ScrollPhysics? parent}) : super(parent: parent);

  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(itemExtent: itemExtent, parent: buildParent(ancestor));
  }

  double _getTargetPixels(ScrollMetrics position, Tolerance tolerance, double velocity) {
    final double pixelsPerMinute = 20.0; // spacing between ticks
    final double currentMinutes = 5 + position.pixels / pixelsPerMinute;

    // Always snap to nearest multiple of 5
    final int snappedMinutes = (currentMinutes / 5).round() * 5;

    // Clamp within allowed range (5 to 180)
    final int clampedMinutes = snappedMinutes.clamp(5, 180);

    return (clampedMinutes - 5) * pixelsPerMinute;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);

    if ((velocity.abs() < tolerance.velocity) && (position.pixels - target).abs() < tolerance.distance) {
      return null;
    }

    final spring = SpringDescription(
      mass: 1,
      stiffness: 50,  // Lower stiffness for softer snap
      damping: 15,    // Adjust damping for less oscillation
    );

    return ScrollSpringSimulation(spring, position.pixels, target, velocity, tolerance: tolerance);

  }

  @override
  bool get allowImplicitScrolling => false;
}

class TimerSlider extends StatefulWidget {
  final int initialMinutes;
  final ValueChanged<int> onChanged;

  const TimerSlider({
    super.key,
    required this.initialMinutes,
    required this.onChanged,
  });

  @override
  State<TimerSlider> createState() => _TimerSliderState();
}

class _TimerSliderState extends State<TimerSlider> {
  late ScrollController _scrollController;
  final double _tickSpacing = 20.0;
  bool _isSnapping = false;
  int _selectedMinutes = 5;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double targetScroll = (widget.initialMinutes - 5) * _tickSpacing;
      _scrollController.jumpTo(targetScroll);
      widget.onChanged(widget.initialMinutes);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isSnapping) return;

    final double offset = _scrollController.offset;

    // Calculate approximate minute (each tick = 1 minute)
    int minute = 5 + (offset / _tickSpacing).round();

    // Snap to nearest major tick (multiple of 5)
    int snappedMinute = ((minute / 5).round()) * 5;
    snappedMinute = snappedMinute.clamp(5, 180);

    if (_selectedMinutes != snappedMinute) {
      _selectedMinutes = snappedMinute;
      widget.onChanged(snappedMinute);
    }
  }

  void _onScrollEnd() {
    final double offset = _scrollController.offset;

    int minute = 5 + (offset / _tickSpacing).round();

    int snappedMinute = ((minute / 5).round()) * 5;
    snappedMinute = snappedMinute.clamp(5, 180);

    final double targetScroll = (snappedMinute - 5) * _tickSpacing;

    _isSnapping = true;
    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    ).then((_) {
      _isSnapping = false;
      _selectedMinutes = snappedMinute;
      widget.onChanged(snappedMinute);
    });
  }


  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        _onScrollEnd();
        return true;
      },
      child: SizedBox(
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: SnappingScrollPhysics(itemExtent: _tickSpacing * 5),
              itemCount: 180 - 4,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 2 - _tickSpacing / 2,
              ),
              itemBuilder: (context, index) {
                final minute = index + 5;
                final isMajorTick = minute % 5 == 0;
                final tickHeight = isMajorTick ? 40.0 : 15.0;

                // Calculate opacity relative to center position
                final centerMajorIndex = (_selectedMinutes - 5) ~/ 1; // index of selected minute (only major ticks selected)
                final opacity = 1.0 - (minute - _selectedMinutes).abs() * 0.1;
                final colorOpacity = opacity.clamp(0.2, 1.0);

                return Container(
                  width: _tickSpacing,
                  alignment: Alignment.center,
                  child: Container(
                    width: 2,
                    height: tickHeight,
                    color: Colors.grey.withOpacity(colorOpacity),
                  ),
                );
              },
            ),
            Positioned(
              child: Container(
                width: 3,
                height: 60,
                color: const Color.fromARGB(255, 244, 235, 54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
