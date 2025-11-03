import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focus_timer_app/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../logic/timer_controller.dart';
import '../../logic/task_provider.dart';
import '../pages/set_timer_page.dart';
import '../pages/to_do_page.dart';
import 'dart:math';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with TickerProviderStateMixin {
  final List<String> _modes = const ["Focus", "Short Break", "Long Break"];
  late final PageController _modePageController;
  final PageController _mainPageController = PageController(initialPage: 0);

  late final ConfettiController _confettiController;

  bool _showFinishedMessage = false;
  String? _lastTaskTitle;


  @override
  void initState() {
    super.initState();
    final timer = Provider.of<TimerController>(context, listen: false);
    _modePageController = PageController(initialPage: timer.selectedMode);

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

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

  @override
  void dispose() {
    _modePageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildFadingPage({
    required PageController controller,
    required int index,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double opacity = 1.0;
        if (controller.hasClients && controller.positions.isNotEmpty) {
          final pageOffset = controller.page ?? controller.initialPage.toDouble();
          final distance = (pageOffset - index);
          opacity = (1 - distance.abs() * 0.4).clamp(0.50, 1.0);
          opacity = Curves.easeInOut.transform(opacity);
        }
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }

  int? _getSelectedTaskIndex(TaskProvider taskProvider) {
    final selectedTaskTitle = taskProvider.selectedTaskTitle;
    final tasks = taskProvider.getTasksForDate(DateTime.now());
    if (selectedTaskTitle == null) return null;

    // Reset completedFocusSessions if task changed
    if (_lastTaskTitle != selectedTaskTitle) {
      _lastTaskTitle = selectedTaskTitle;
      Provider.of<TimerController>(context, listen: false).completedFocusSessions = 0;
    }

    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i]['title'] == selectedTaskTitle) return i;
    }
    return null;
  }



  final List<String> _motivationalMessages = [
    "Let’s crush: {task} 💪",
    "Stay focused on: {task} 🔥",
    "You got this: {task} 🚀",
    "In the zone: {task}",
    "Focus power: {task} ⚡",
  ];

  final Map<String, String> _taskMotivationalCache = {};

  String getMotivationalText(String taskTitle) {
    // If we already have a message for this task, return it
    if (_taskMotivationalCache.containsKey(taskTitle)) {
      return _taskMotivationalCache[taskTitle]!;
    }

    // Otherwise, pick a random one and store it
    final random = Random();
    final message = _motivationalMessages[random.nextInt(_motivationalMessages.length)]
        .replaceAll("{task}", taskTitle);
    _taskMotivationalCache[taskTitle] = message;
    return message;
  }

  // Optional: clear the cache when task completes
  void clearTaskMessage(String taskTitle) {
    _taskMotivationalCache.remove(taskTitle);
  }


  double get timerProgress {
    final timer = Provider.of<TimerController>(context, listen: true);
    if (timer.initialSeconds == 0) return 0.0;
    return 1.0 - (timer.remainingSeconds / timer.initialSeconds);
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String buttonText(TimerController timer) {
    if (timer.isRunning) return 'Pause';
    if (timer.remainingSeconds != timer.initialSeconds) return 'Resume';
    return 'Start';
  }

  Future<void> _checkTaskCompletion(TaskProvider taskProvider) async {
    final selectedTaskTitle = taskProvider.selectedTaskTitle;
    if (selectedTaskTitle == null) return;

    await taskProvider.fetchTasksForDate(DateTime.now());
    final todayTasks = taskProvider.getTasksForDate(DateTime.now());
    final task = todayTasks.firstWhere(
      (t) => t['title'] == selectedTaskTitle,
      orElse: () => {},
    );

    if (task.isEmpty) return;

    if ((task['donePomodoros'] ?? 0) >= (task['pomodoros'] ?? 0)) {
      if (!mounted) return;
      _confettiController.play();
      setState(() => _showFinishedMessage = true);

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _showFinishedMessage = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerController>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: timer.isRunning ? darkAppBackground : lightAppBackground,
      child: PageView(
        controller: _mainPageController,
        physics: timer.isRunning
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        children: [
          // === Timer Screen ===
          _buildFadingPage(
            controller: _mainPageController,
            index: 0,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 0,
              ),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  // Confetti
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      numberOfParticles: 60,
                      maxBlastForce: 30,
                      minBlastForce: 15,
                      gravity: 0.3,
                      shouldLoop: false,
                      colors: const [
                        Colors.yellow,
                        Colors.purple,
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange
                      ],
                    ),
                  ),

                  // === Finished Task Message ===
                  if (_showFinishedMessage)
                    Positioned(
                      top: 150,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: _showFinishedMessage ? 1 : 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: purpleCtaColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            "🎉 Task Finished!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  Consumer2<TaskProvider, TimerController>(
                    builder: (context, taskProvider, timerController, _) {
                      final selectedTaskTitle = taskProvider.selectedTaskTitle;
                      if (selectedTaskTitle == null) return const SizedBox.shrink();

                      final todayTasks = taskProvider.getTasksForDate(DateTime.now());
                      final task = todayTasks.firstWhere(
                        (t) => t['title'] == selectedTaskTitle,
                        orElse: () => {},
                      );

                      if (task.isEmpty || (task['donePomodoros'] >= task['pomodoros'])) {
                        return const SizedBox.shrink();
                      }

                      final isFocusMode = timerController.selectedMode == 0;
                      final isRunning = timerController.isRunning;

                      // Hide during breaks
                      if (!isFocusMode && isRunning) return const SizedBox.shrink();

                      return Positioned(
                        top: 150,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: isRunning && isFocusMode
                              ? Text(
                                  getMotivationalText(task['title']),
                                  key: ValueKey('textOnly-${task['title']}'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: yellowTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Container(
                                  key: ValueKey('pill-${task['title']}'),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: purpleCtaColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("🕓 ", style: TextStyle(fontSize: 20)),
                                      Text(
                                        "Next Task: ${task['title']}",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: yellowTextColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      );
                    },
                  ),




                  // === Main Timer Column ===
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Mode Selector
                              SizedBox(
                                height: 40,
                                width: 150,
                                child: AnimatedBuilder(
                                  animation: _modePageController,
                                  builder: (context, child) {
                                    final page = _modePageController.hasClients
                                        ? _modePageController.page ?? _modePageController.initialPage.toDouble()
                                        : _modePageController.initialPage.toDouble();

                                    return PageView.builder(
                                      controller: _modePageController,
                                      physics: timer.isRunning
                                          ? const NeverScrollableScrollPhysics()
                                          : const PageScrollPhysics(),
                                      itemCount: _modes.length,
                                      onPageChanged: (index) => timer.setMode(index),
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
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: timer.isRunning
                                                        ? yellowTextColor
                                                        : darkAppBackground,
                                                    fontSize: 25,
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

                              const SizedBox(height: 40),

                              // Timer Display
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 1.0,
                                  end: timer.isRunning ? 1.05 : 1.0,
                                ),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 500),
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontSize: 85,
                                            color: timer.isRunning
                                                ? yellowTextColor
                                                : Theme.of(context).iconTheme.color,
                                          ),
                                      child: GestureDetector(
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
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              if (timer.isRunning)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                  child: SizedBox(
                                    height: 8,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Container(
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: yellowTextColor.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                        AnimatedBuilder(
                                          animation: Provider.of<TimerController>(context),
                                          builder: (context, child) {
                                            final progress = timerProgress;
                                            return Align(
                                              alignment: Alignment.centerLeft,
                                              child: FractionallySizedBox(
                                                widthFactor: progress,
                                                child: Container(
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: yellowTextColor,
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 40),

                              // Start/Pause Button
                              TextButton(
                                onPressed: () {
                                  if (timer.isRunning) {
                                    timer.pause();
                                  } else {
                                    timer.start(
                                      onComplete: () async {
                                        final taskProvider = Provider.of<TaskProvider>(context, listen: false);

                                        if (timer.selectedMode == 0) { // Focus session finished
                                          final index = _getSelectedTaskIndex(taskProvider);
                                          bool taskJustFinished = false;

                                          if (index != null) {
                                            await taskProvider.fetchTasksForDate(DateTime.now());
                                            final todayTasks = taskProvider.getTasksForDate(DateTime.now());
                                            final task = todayTasks[index];

                                            // Only increment if task not done
                                            if ((task['donePomodoros'] ?? 0) < (task['pomodoros'] ?? 0)) {
                                              await taskProvider.incrementPomodoro(DateTime.now(), index);

                                              // Check if task is now finished
                                              if ((task['donePomodoros'] ?? 0) + 1 >= (task['pomodoros'] ?? 0)) {
                                                taskJustFinished = true;
                                                await _checkTaskCompletion(taskProvider); // show confetti
                                              }
                                            }
                                          }

                                          if (taskJustFinished) {
                                            // Skip break, go straight to focus
                                            timer.setMode(0);
                                          } else {
                                            // Normal Pomodoro flow
                                            timer.completedFocusSessions++;
                                            if (timer.completedFocusSessions % 4 == 0) {
                                              timer.setMode(2); // Long break every 4 focus sessions
                                            } else {
                                              timer.setMode(1); // Short break
                                            }
                                          }

                                          timer.reset();
                                        } else { // Break finished
                                          timer.setMode(0); // Always go back to focus
                                          timer.reset();
                                        }
                                      },
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: timer.isRunning ? purpleCtaColor : ctaColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                ),
                                child: Text(
                                  buttonText(timer),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: timer.isRunning ? yellowTextColor : Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),




                              SizedBox(
                                height: 60,
                                child: timer.remainingSeconds != timer.initialSeconds
                                    ? IconButton(
                                        onPressed: timer.reset,
                                        icon: const Icon(Icons.refresh),
                                        tooltip: 'Reset Timer',
                                        color: purpleCtaColor,
                                        iconSize: 30,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // === To-do Page ===
          _buildFadingPage(
            controller: _mainPageController,
            index: 1,
            child: const TodoPage(),
          ),
        ],
      ),
    );
  }
}
