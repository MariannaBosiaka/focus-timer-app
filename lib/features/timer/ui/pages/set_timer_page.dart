import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../../../themes/colors.dart';

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
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_minutes',
              style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 100),
            ),
            const SizedBox(height: 80),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTickMarkColor: Colors.transparent,
                activeTrackColor: lightAppBackground,
                inactiveTrackColor: Colors.transparent,
                thumbColor: lightAppBackground,
                overlayColor: Colors.transparent, 
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 0), 
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                trackHeight: 4,
              ),
              child: Slider(
                value: _minutes.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                label: null, // no label popup
                onChanged: (value) {
                  setState(() {
                    _minutes = value.round();
                  });
                },
              ),
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
    );
  }
}
