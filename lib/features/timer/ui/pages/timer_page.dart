import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focus_timer_app/themes/colors.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/task_provider.dart';
import '../pages/set_timer_page.dart';
import '../pages/to_do_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final List<String> _modes = const ["Focus", "Short Break", "Long Break"];
  String? _selectedTaskTitle;
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

  @override
  void dispose() {
    _modePageController.dispose();
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
    final tasks = taskProvider.getTasksForDate(DateTime.now());
    if (_selectedTaskTitle == null) return null;
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i]['title'] == _selectedTaskTitle) return i;
    }
    return null;
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
        physics: const PageScrollPhysics(),
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
              body: Column(
                children: [
                  const SizedBox(height: 20),

                  // Dropdown of today's tasks
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, _) {
                      final today = DateTime.now();
                      final todayTasks = taskProvider.getTasksForDate(today);
                      if (todayTasks.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "No tasks for today",
                            style: TextStyle(fontSize: 17, color: Colors.grey),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonHideUnderline(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text("Select a task"),
                              value: _selectedTaskTitle,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTaskTitle = value;
                                });
                              },
                              items: todayTasks.map((task) {
                                return DropdownMenuItem<String>(
                                  value: task['title'],
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      task['title'],
                                      style: const TextStyle(fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 185, 13, 13),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(height: 40),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: ctaColor,
                                  size: 24,
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                offset: Offset(
                                  0,
                                  -MediaQuery.of(context).size.height * 0.007,
                                ),
                                elevation: 0,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 247, 247, 247),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                maxHeight: 200,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                  itemCount: _modes.length,
                                  onPageChanged: (index) {
                                    timer.setMode(index);
                                  },
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

                          // Smoothly scale timer when running and stay big
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
                                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                                    fontSize: 85,
                                    color: timer.isRunning ? yellowTextColor : Theme.of(context).iconTheme.color,
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

                          const SizedBox(height: 50),

                          // Start/Pause Button
                          TextButton(
                            onPressed: () {
                              if (timer.isRunning) {
                                timer.pause();
                              } else {
                                timer.start(
                                  onComplete: () {
                                    if (timer.selectedMode == 0) {
                                      if (_selectedTaskTitle != null) {
                                        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                                        final index = _getSelectedTaskIndex(taskProvider);
                                        if (index != null) {
                                          taskProvider.incrementPomodoro(DateTime.now(), index);
                                        }
                                      }

                                      timer.completedFocusSessions++;

                                      if (timer.completedFocusSessions % 4 == 0) {
                                        timer.setMode(2);
                                      } else {
                                        timer.setMode(1);
                                      }

                                      timer.reset();
                                    } else if (timer.selectedMode == 1 || timer.selectedMode == 2) {
                                      timer.setMode(0);
                                      timer.reset();
                                    }
                                  },
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: ctaColor,
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(
                              buttonText(timer),
                              style: const TextStyle(fontSize: 17),
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
                                    color: Theme.of(context).iconTheme.color,
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
