import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../../../themes/colors.dart';
import 'package:flutter/services.dart';

class SetTimerPage extends StatefulWidget {
  final int initialMinutes;
  final int selectedMode;

  const SetTimerPage({
    super.key,
    required this.initialMinutes,
    required this.selectedMode,
  });

  @override
  State<SetTimerPage> createState() => _SetTimerPageState();
}

class _SetTimerPageState extends State<SetTimerPage> {
  late final FixedExtentScrollController _scrollController;
  late int _minutes;
  late int _mode;

  // Generate numbers 5 → 185 (increments of 5)
  final List<int> _values = List.generate(37, (i) => (i + 1) * 5);

  @override
  void initState() {
    super.initState();

    _minutes = widget.initialMinutes;
    _mode = widget.selectedMode;

    int initialIndex = _values.indexOf(widget.initialMinutes);
    if (initialIndex == -1) {
      initialIndex = _values.indexOf(25);
      _minutes = 25;
    }

    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar icons to light
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final timer = Provider.of<TimerController>(context, listen: false);

    return Scaffold(
      backgroundColor: darkAppBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar (back arrow + text)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: yellowTextColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set The',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: yellowTextColor,
                            ),
                          ),
                          Text(
                            'Timer',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: yellowTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main content column (wheel + mode selector + button)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wheel + Mode selector row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left side: scrolling minutes
                        SizedBox(
                          height: 195,
                          width: 155,
                          child: ListWheelScrollView.useDelegate(
                            controller: _scrollController,
                            itemExtent: 95,
                            perspective: 0.001,
                            physics: const FixedExtentScrollPhysics(),
                            overAndUnderCenterOpacity: 0.5,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _minutes = _values[index];
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: _values.length,
                              builder: (context, index) {
                                final value = _values[index];
                                final isSelected = value == _minutes;

                                return AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 150),
                                  style: TextStyle(
                                    fontSize: 85,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                    color: isSelected
                                        ? yellowTextColor
                                        : yellowTextColor.withOpacity(0.3),
                                  ),
                                  child: Text('$value'),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 40),

                        // Right side: vertical mode selector
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildModeButton(context, timer, 0, "Focus"),
                            const SizedBox(height: 30),
                            _buildModeButton(context, timer, 1, "Short break"),
                            const SizedBox(height: 30),
                            _buildModeButton(context, timer, 2, "Long break"),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    // Dynamic "Set [Mode]" button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctaColor,
                        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        final duration = Duration(minutes: _minutes);
                        timer.updateDurationForMode(_mode, duration);
                        Navigator.pop(context);
                      },
                      child: Text(
                        _mode == 0
                            ? "Set Focus"
                            : _mode == 1
                                ? "Set Short Break"
                                : "Set Long Break",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkAppBackground,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
      BuildContext context, TimerController timer, int mode, String label) {
    final bool isSelected = _mode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
        });
        timer.setMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ctaColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? darkAppBackground : yellowTextColor,
            fontSize: 16,
            fontWeight: isSelected?FontWeight.bold : FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
