import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focus_timer_app/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../logic/timer_controller.dart';
import '../../logic/task_provider.dart';
import '../pages/set_timer_page.dart';
import '../pages/to_do_page.dart';

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

  int? _getSelectedTaskIndex(TaskProvider taskProvider) {
    final selectedTaskTitle = taskProvider.selectedTaskTitle;
    final tasks = taskProvider.getTasksForDate(DateTime.now());
    if (selectedTaskTitle == null) return null;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i]['title'] == selectedTaskTitle) return i;
    }
    return null;
  }

    Future<void> _checkTaskCompletion(TaskProvider taskProvider) async {
    final selectedTaskTitle = taskProvider.selectedTaskTitle;
    if (selectedTaskTitle == null) return;

    // Fetch the latest tasks from Firestore
    await taskProvider.fetchTasksForDate(DateTime.now());

    final todayTasks = taskProvider.getTasksForDate(DateTime.now());
    final task = todayTasks.firstWhere(
      (t) => t['title'] == selectedTaskTitle,
      orElse: () => {},
    );

    if (task.isEmpty) return;

    // Show confetti if task is complete
    if ((task['donePomodoros'] ?? 0) >= (task['pomodoros'] ?? 0)) {
      if (!mounted) return; 
      _confettiController.play();
      setState(() => _showFinishedMessage = true);

      Future.delayed(const Duration(seconds: 3), () {

        if (!mounted) return; 

        if (mounted) {
          setState(() => _showFinishedMessage = false);
        }
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
          ? const NeverScrollableScrollPhysics() // disable swipe when running
          : const PageScrollPhysics(),          // enable swipe otherwise
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
                  // Confetti from top
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive, // downward    // many particles quickly
                      numberOfParticles: 60,    // high number
                      maxBlastForce: 30,
                      minBlastForce: 15,
                      gravity: 0.3,              // fall naturally
                      shouldLoop: false,         // play only once
                      colors: const [
                        Colors.yellow,
                        Colors.purple,
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange
                      ],// optional: make custom shapes
                    ),
                  ),

                  // Finished Task Message
                  if (_showFinishedMessage)
                    Positioned(
                      top: 150,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: _showFinishedMessage ? 1 : 0,
                        // opacity: 1, for testing purposes
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

                  // Main Timer Column
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // --- Display Selected Task ---
                              Consumer<TaskProvider>(
                                builder: (context, taskProvider, _) {
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

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      "Next Task: ${task['title']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: yellowTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),

                              // Mode selector
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
                                      // enable scrolling between modes only when timer is stopped
                                      physics: timer.isRunning
                                      ? const NeverScrollableScrollPhysics()
                                      : const PageScrollPhysics(), 
                                      itemCount: _modes.length,
                                      onPageChanged: (index) => timer.setMode(index),
                                      itemBuilder: (context, index) {
                                        final distance = (page - index).abs();
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
                                                  style: TextStyle
                                                  (
                                                    fontWeight: FontWeight.w600,
                                                    color: timer.isRunning ? yellowTextColor : darkAppBackground,
                                                    fontSize: 25
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

                              // Timer display
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
                              // Smooth White Progress Line with margin
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                child: SizedBox(
                                  height: 8, // total height of the bar
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      // Base thin grey line
                                      Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: yellowTextColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),

                                      // Animated thicker white line filling as timer progresses
                                      AnimatedBuilder(
                                        animation: Provider.of<TimerController>(context),
                                        builder: (context, child) {
                                          final progress = timerProgress; // 0.0 -> 1.0
                                          return Align(
                                            alignment: Alignment.centerLeft,
                                            child: FractionallySizedBox(
                                              widthFactor: progress,
                                              child: Container(
                                                height: 4, // thicker than the base line
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

                                        if (timer.selectedMode == 0) {
                                          final index = _getSelectedTaskIndex(taskProvider);
                                          if (index != null) {
                                            // Increment pomodoro and fetch latest task data
                                            await taskProvider.incrementPomodoro(DateTime.now(), index);

                                            // Trigger confetti & finished message if task done
                                            await _checkTaskCompletion(taskProvider);
                                          }

                                          timer.completedFocusSessions++;
                                          timer.setMode(timer.completedFocusSessions % 4 == 0 ? 2 : 1);
                                          timer.reset();
                                          
                                        } else {
                                          timer.setMode(0);
                                          timer.reset();
                                        }
                                      },
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: timer.isRunning 
                                                      ? purpleCtaColor : ctaColor,
                                  
                                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Text(
                                  buttonText(timer),
                                  style: TextStyle
                                  (
                                    fontSize: 17,
                                    color: timer.isRunning
                                                ? yellowTextColor
                                                : Theme.of(context).iconTheme.color,
                                  ),
                                  textAlign: TextAlign.center,
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
