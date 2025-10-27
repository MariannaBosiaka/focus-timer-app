import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../themes/colors.dart';
import '../../logic/task_provider.dart';
import 'package:provider/provider.dart';
import 'add_edit_tasks_page.dart';
import '../../../timer/ui/pages/timer_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<List<DateTime>> _weeks = [];
  int _currentWeekIndex = 0;
  late PageController _pageController;
  String _selectedFilter = "All"; // Default filter

  @override
  void initState() {
    super.initState();

    _weeks = _generateWeeks();
    _pageController = PageController(viewportFraction: 0.90);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // Fetch tasks for the selected date from Firestore
      taskProvider.fetchTasksForDate(taskProvider.selectedDate);

      final selectedDate = taskProvider.selectedDate;
      final weekIndex = _getWeekIndexForDate(selectedDate);

      Future.delayed(Duration.zero, () {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(weekIndex);
        }
      });
    });
  }


  void _openTaskEditorPage(
  DateTime selectedDate, {
  Map<String, dynamic>? task,
  int? index,
  }) async {
    // Small delay ensures rebuild happens before navigation
    await Future.delayed(Duration(milliseconds: 50));

    // Navigate to Add/Edit task page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTasksPage(
          selectedDate: selectedDate,
          task: task,
          index: index,
        ),
      ),
    );

  }


  List<List<DateTime>> _generateWeeks() {
    List<List<DateTime>> weeks = [];
    DateTime start = DateTime.now();
    start = start.subtract(Duration(days: start.weekday - 1));

    for (int i = 0; i < 52; i++) {
      List<DateTime> week = List.generate(
        7,
        (index) => start.add(Duration(days: index)),
      );
      weeks.add(week);
      start = start.add(const Duration(days: 7));
    }
    return weeks;
  }

  List<Map<String, dynamic>> _filteredTasks(List<Map<String, dynamic>> tasks) {
  switch (_selectedFilter) {
    case "To Do":
      return tasks.where((task) => task['done'] == false).toList();
    case "Completed":
      return tasks.where((task) => task['done'] == true).toList();
    default:
      return tasks; // All
  }
}


  String _currentMonth(DateTime selectedDate) {
    return DateFormat('MMMM').format(selectedDate);
  }

  int _getWeekIndexForDate(DateTime date) {
    for (int i = 0; i < _weeks.length; i++) {
      if (_weeks[i].any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      )) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final selectedDate = taskProvider.selectedDate;
    final tasksForDay = taskProvider.tasksForSelectedDate;
    final filteredTasksForDay = _filteredTasks(tasksForDay);

    if (_weeks.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: darkAppBackground,
      appBar: AppBar(
        backgroundColor: darkAppBackground,
        toolbarHeight: 90,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _currentMonth(selectedDate),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: yellowTextColor,
                  ),
                ),
              ),
              Text(
                DateFormat('EEE d, yyyy').format(selectedDate),
                style: TextStyle(fontSize: 18, color: yellowTextColor),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Week selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _weeks.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentWeekIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final week = _weeks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: week.map((day) {
                                final isSelected =
                                    day.day == selectedDate.day &&
                                    day.month == selectedDate.month;

                                return GestureDetector(
                                  onTap: () {
                                    Provider.of<TaskProvider>(
                                      context,
                                      listen: false,
                                    ).setSelectedDate(day);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('EEEE').format(day).substring(0, 1),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? ctaColor : yellowTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? ctaColor : yellowTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isSelected ? ctaColor : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: lightAppBackground,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: ["All", "To Do", "Completed"].map((filter) {
                            final isSelected = _selectedFilter == filter;

                            // Count tasks per category
                            int count;
                            switch (filter) {
                              case "To Do":
                                count = tasksForDay.where((t) => t['done'] == false).length;
                                break;
                              case "Completed":
                                count = tasksForDay.where((t) => t['done'] == true).length;
                                break;
                              default:
                                count = tasksForDay.length;
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? ctaColor : purpleCtaColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      filter,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? darkAppBackground : yellowTextColor,
                                      ),
                                    ),
                                    if (count > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        "($count)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? darkAppBackground.withValues(alpha: 0.8)
                                              : yellowTextColor.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: tasksForDay.isEmpty
                            ? Center(
                                child: Text(
                                  "No tasks yet. Add something!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                itemCount: filteredTasksForDay.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasksForDay[index];
                                  final taskKey = GlobalKey();
                                  double taskHeight = 100;

                                  return StatefulBuilder(
                                    builder: (context, setStateSB) {
                                      // measure task height
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        final renderBox = taskKey.currentContext?.findRenderObject() as RenderBox?;
                                        if (renderBox != null && renderBox.size.height != taskHeight) {
                                          setStateSB(() {
                                            taskHeight = renderBox.size.height;
                                          });
                                        }
                                      });

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [

                                            // Foreground task box
                                            Slidable(
                                              key: ValueKey("${task['title']}_${index}_${_selectedFilter}_${selectedDate.toIso8601String()}"),

                                              // LEFT SIDE (swipe right)
                                              startActionPane: ActionPane(
                                                motion: const BehindMotion(),
                                                extentRatio: 0.2,
                                                dismissible: null,
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (context) {
                                                      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                                                      taskProvider.setSelectedTaskTitle(task['title']);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (_) => const TimerPage()),
                                                      );
                                                    },
                                                    backgroundColor: darkAppBackground,
                                                    borderRadius: BorderRadius.circular(30),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.star,
                                                        color: yellowTextColor,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // RIGHT SIDE (swipe left)
                                              endActionPane: ActionPane(
                                                motion: const BehindMotion(),
                                                extentRatio: 0.2,
                                                dismissible: DismissiblePane(
                                                  onDismissed: () async {
                                                    final provider = Provider.of<TaskProvider>(context, listen: false);
                                                    await provider.removeTask(selectedDate, index);
                                                  },
                                                ),
                                                children: [
                                                  CustomSlidableAction(
                                                    onPressed: (context) async {
                                                      final provider = Provider.of<TaskProvider>(context, listen: false);
                                                      await provider.removeTask(selectedDate, index);
                                                    },
                                                    backgroundColor: darkAppBackground,
                                                    borderRadius: BorderRadius.circular(30),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.delete,
                                                        color: ctaColor,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              child: GestureDetector(
                                                onTap: () {

                                                  if (task['done'] == true) {
                                                    return;
                                                  }

                                                  _openTaskEditorPage(selectedDate, task: task, index: index);
                                                },
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    key: taskKey,
                                                    width: MediaQuery.of(context).size.width * 0.9,
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                                    decoration: BoxDecoration(
                                                      color: purpleCtaColor,
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        // Done button
                                                        GestureDetector(
                                                          onTap: () {
                                                            Provider.of<TaskProvider>(
                                                              context,
                                                              listen: false,
                                                            ).toggleDone(selectedDate, index);
                                                          },
                                                          child: Container(
                                                            width: 45,
                                                            height: 45,
                                                            alignment: Alignment.center,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: task['done'] ? ctaColor : lightAppBackground,
                                                            ),
                                                            child: task['done']
                                                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                                                : null,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 20),

                                                        // Task content
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              // Title + Category
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      task['title'],
                                                                      style: TextStyle(
                                                                        fontSize: 18,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: task['done']
                                                                            ? Theme.of(context).hintColor
                                                                            : Theme.of(context).brightness == Brightness.light
                                                                                ? yellowTextColor
                                                                                : lightAppBackground,
                                                                        decoration: task['done'] ? TextDecoration.lineThrough : null,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if ((task['category'] ?? '').isNotEmpty)
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: ctaColor,
                                                                        borderRadius: BorderRadius.circular(12),
                                                                      ),
                                                                      child: Text(
                                                                        task['category'],
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w600,
                                                                          color: darkAppBackground,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),

                                                              // Description
                                                              if ((task['description'] ?? '').isNotEmpty)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 2),
                                                                  child: Text(
                                                                    task['description'],
                                                                    maxLines: 2,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: yellowTextColor50,
                                                                    ),
                                                                  ),
                                                                ),

                                                              // Pomodoro sessions
                                                              if (task['pomodoros'] > 0)
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 6),
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                                                                    decoration: BoxDecoration(
                                                                      color: lightAppBackground,
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Text(
                                                                      "${task['donePomodoros']}/${task['pomodoros']} sessions",
                                                                      style: TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.w600,
                                                                        color: yellowTextColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Add Task button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: GestureDetector(
                onTap: () => _openTaskEditorPage(selectedDate),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ctaColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 30, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
