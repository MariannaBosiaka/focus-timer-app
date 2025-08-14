import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/theme_provider.dart';
import '../pages/set_timer_page.dart';
import '../pages/to_do_page.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<String> _modes = const ["Focus", "Short Break", "Long Break"];

  late final PageController _modePageController;
  final PageController _mainPageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    final timer = Provider.of<TimerController>(context, listen: false);
    _modePageController = PageController(initialPage: timer.selectedMode);

    // Keep mode selector in sync with timer
    timer.addListener(() {
      if (_modePageController.hasClients &&
          _modePageController.page?.round() != timer.selectedMode) {
        _modePageController.animateToPage(
          timer.selectedMode,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
      body: PageView(
        controller: _mainPageController,
        physics: const PageScrollPhysics(),
        children: [
          // === Timer Screen ===
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Mode selector with blur
                SizedBox(
                  height: 40,
                  width: 150,
                  child: AnimatedBuilder(
                    animation: _modePageController,
                    builder: (context, child) {
                      final page = _modePageController.hasClients
                          ? _modePageController.page ??
                              _modePageController.initialPage.toDouble()
                          : _modePageController.initialPage.toDouble();

                      return PageView.builder(
                        controller: _modePageController,
                        itemCount: _modes.length,
                        onPageChanged: (index) {
                          timer.setMode(index);
                        },
                        itemBuilder: (context, index) {
                          final distance = (page - index).abs();
                          final blurAmount = (distance == 0)
                              ? 0.0
                              : (distance * 5).clamp(0.0, 5.0);
                          final opacity = (distance == 0)
                              ? 1.0
                              : (1 - (distance * 0.5)).clamp(0.0, 1.0);

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
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).iconTheme.color,
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

                // Timer text
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
                        .copyWith(fontSize: 85),
                  ),
                ),

                const SizedBox(height: 50),

                // Start / Pause
                TextButton(
                  onPressed: () {
                    if (timer.isRunning) {
                      timer.pause();
                    } else {
                      timer.start();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    buttonText(timer),
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
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

          // === To-do Page ===
          const TodoPage(),
        ],
      ),
    );
  }
}
