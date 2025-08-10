import 'package:flutter/material.dart';
import 'package:focus_timer_app/features/timer/ui/pages/set_timer_page.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/theme_provider.dart'; 
import '../widgets/mode_selector.dart'; 


class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String buttonText(TimerController timer) {
    if (timer.isRunning) {
      return 'Pause';
    } else if (timer.remainingSeconds != timer.initialSeconds) {
      return 'Resume';
    } else {
      return 'Start';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerController>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.wb_sunny
                  : Icons.nights_stay,
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.yellow
                  : Colors.grey[800],
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8), // optional spacing
        ],
      ),
      body: Center(
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Positioned(
                top: 40,
                left: 0,
                right: 0,
                child:ModeSelector(
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
                  };
                },
              ),
              ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SetTimerPage(initialMinutes: timer.remainingSeconds ~/ 60,),
                    ),
                  );
                },
                child: Text(
                  formatTime(timer.remainingSeconds),
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 80),
                ),
              ),

            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                if (timer.isRunning) {
                  timer.pause();
                } else {
                  timer.start();
                }
              },
              style: TextButton.styleFrom(
                fixedSize: const Size(100, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(buttonText(timer)),
            ),
            SizedBox(
              height: 60, 
              child: timer.remainingSeconds != timer.initialSeconds
                  ? IconButton(
                      onPressed: timer.reset,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset Timer',
                      color: Theme.of(context).iconTheme.color,
                      iconSize: 30,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
