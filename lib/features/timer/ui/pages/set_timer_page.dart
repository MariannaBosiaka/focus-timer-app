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
  int _mode = 0;

  String modeButtonText(int mode) {
    if (mode == 0) {
      return 'Set Timer';
    } else if (mode == 1) {
      return 'Set Short Break';
    } else {
      return 'Set Long Break';
    }
  }

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
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 80), 
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
                Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child:ModeSelector(
                    onModeChanged: (index) {
                      setState(() {
                        _mode = index;
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
                      });
                    },
                  ),
                  ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    timer.setDuration(Duration(minutes: _minutes));
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 45), // height fixed, width flexible
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(modeButtonText(_mode)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
