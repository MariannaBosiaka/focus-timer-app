import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/theme_provider.dart';  // import ThemeProvider here

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
    } else if (timer.remainingSeconds != TimerController.initialSeconds) {
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
      // backgroundColor: const Color.fromARGB(255, 28, 30, 33),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formatTime(timer.remainingSeconds),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
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
            if (timer.remainingSeconds != TimerController.initialSeconds)
              const SizedBox(height: 10),
            if (timer.remainingSeconds != TimerController.initialSeconds)
              TextButton(
                onPressed: timer.reset,
                style: TextButton.styleFrom(
                  fixedSize: const Size(75, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Reset'),
              ),
          ],
        ),
      ),
    );
  }
}
