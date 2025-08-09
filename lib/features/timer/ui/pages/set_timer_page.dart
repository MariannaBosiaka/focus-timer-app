import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../../../themes/colors.dart';
import '../widgets/timer_slider.dart';
import '../widgets/mode_selector.dart';

class SetTimerPage extends StatefulWidget {
  final int initialMinutes;

  const SetTimerPage({super.key, required this.initialMinutes});

  @override
  State<SetTimerPage> createState() => _SetTimerPageState();
}



class _SetTimerPageState extends State<SetTimerPage> {
  int _minutes = 25;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ModeSelector at the top
          Positioned(
            top: 40, // Adjust as needed
            left: 0,
            right: 0,
            child: ModeSelector(
              onModeChanged: (index) {
                switch (index) {
                  case 0:
                    timer.setDuration(const Duration(minutes: 25));
                    break;
                  case 1:
                    timer.setDuration(const Duration(minutes: 5));
                    break;
                  case 2:
                    timer.setDuration(const Duration(minutes: 15));
                    break;
                }
              },
            ),
          ),

          // Main content in the center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 80), // Leave space below ModeSelector
                Text(
                  '$_minutes',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 100),
                ),
                const SizedBox(height: 80),
                TimerSlider(
                  initialMinutes: _minutes,
                  onChanged: (value) {
                    setState(() {
                      _minutes = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    timer.setDuration(Duration(minutes: _minutes));
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    fixedSize: const Size(100, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Set Timer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
