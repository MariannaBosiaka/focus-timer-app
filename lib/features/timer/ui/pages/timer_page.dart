import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:focus_timer_app/themes/colors.dart';
import 'package:provider/provider.dart';
import '../../logic/timer_controller.dart';
import '../../logic/theme_provider.dart';
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

  late final PageController _modePageController;
  final PageController _mainPageController = PageController(initialPage: 0);

  Widget _buildFadingPage({
    required PageController controller,
    required int index,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        double opacity = 1.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          final pageOffset =
              controller.page ?? controller.initialPage.toDouble();
          final distance = (pageOffset - index).abs();
          opacity = (1 - (distance * 1.5)).clamp(0.0, 1.0);
        }
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
    );
  }

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
          // === Timer Screen with fade ===
          _buildFadingPage(
            controller: _mainPageController,
            index: 0,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Dropdown of today's tasks (near top)
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

                    String? selectedTask;

                    //drop down menu
                    return StatefulBuilder(
                      builder: (context, setState) {
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
                                value: selectedTask,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTask = value;
                                  });
                                },
                                
                                items: todayTasks.map((task) {
                                  return DropdownMenuItem<String>(
                                    value: task['title'],
                                    child: Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        task['title'],
                                        style: const TextStyle(fontSize: 17),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, 
                                      ),
                                    ),
                                  );
                                }).toList(),

                                buttonStyleData: ButtonStyleData(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 244, 244, 244),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                      Icons.keyboard_arrow_down, // your preferred arrow icon
                                      color: ctaColor,  // purple color
                                      size: 24,
                                    ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  offset: Offset(
                                    0, -MediaQuery.of(context).size.height * 0.007
                                  ),
                                  elevation: 0, // REMOVE shadow
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 244, 244, 244), // match button color
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  maxHeight: 200,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

   
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  
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
                                                color: Theme.of(context)
                                                    .iconTheme
                                                    .color,
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
                                initialMinutes:
                                    timer.remainingSeconds ~/ 60,
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
                          backgroundColor: ctaColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 12),
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
              ],
            ),
          ),

          // === To-do Page with fade ===
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
