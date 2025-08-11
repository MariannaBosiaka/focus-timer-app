import 'package:flutter/material.dart';
import 'package:focus_timer_app/features/timer/ui/pages/set_timer_page.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/theme_provider.dart'; 
import '../widgets/swipe_mode_main_timer.dart';
import 'dart:ui'; 

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<String> _modes = const ["Focus", "Short Break", "Long Break"];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final timer = Provider.of<TimerController>(context, listen: false);
    _pageController = PageController(initialPage: timer.selectedMode);

    // Listen to timer.selectedMode changes to update PageView
    timer.addListener(() {
      if (_pageController.hasClients &&
          _pageController.page?.round() != timer.selectedMode) {
        _pageController.animateToPage(
          timer.selectedMode,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 40,
                width: 150,
                child: AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    final page = _pageController.hasClients ? _pageController.page ?? _pageController.initialPage.toDouble() : _pageController.initialPage.toDouble();

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: _modes.length,
                      onPageChanged: (index) {
                        timer.setMode(index);
                      },
                      itemBuilder: (context, index) {

                      final distance = (page - index).abs();

                      // If the page is exactly at the index (initially), no blur:
                      final blurAmount = (distance == 0) ? 0.0 : (distance * 5).clamp(0.0, 5.0);
                      final opacity = (distance == 0) ? 1.0 : (1 - (distance * 0.5)).clamp(0.0, 1.0);

                        return Center(
                          child: Opacity(
                            opacity: opacity,
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: blurAmount,
                                  sigmaY: blurAmount,
                                ),
                                child: Text(
                                  _modes[index],
                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 50),

            // Tap timer to edit
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SetTimerPage(
                      initialMinutes: timer.remainingSeconds ~/ 60,
                      selectedMode: timer.selectedMode,
                    ),
                  ),
                );
              },
              child: Text(
                formatTime(timer.remainingSeconds),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(fontSize: 80),
              ),
            ),

            const SizedBox(height: 50),

            // Start/Pause Button
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
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(buttonText(timer)),
            ),

            // Reset Button
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
