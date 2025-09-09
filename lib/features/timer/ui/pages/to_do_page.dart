import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; 
import '../../../../themes/colors.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Map<String, dynamic>> _tasks = []; 
  List<List<DateTime>> _weeks = [];
  int _currentWeekIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _weeks = _generateWeeks();
    if (_weeks.isNotEmpty) {
      _selectedDate = _weeks[_currentWeekIndex][0];
    }
  }

  void _openTaskBottomSheet({Map<String, dynamic>? task, int? index}) {
    final TextEditingController taskController = TextEditingController(
      text: task?['title'] ?? "",
    );
    int newPomodoros = task?['pomodoros'] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (context) {
        final fieldColor =
            Theme.of(context).brightness == Brightness.light
                ? lightAppBackground
                : darkAppBackground;

        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 9),
                      Text(
                        task == null ? "Add New Task" : "Edit Task",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Task Title
                      Text(
                        "Title",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: fieldColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(minHeight: 60),
                        child: TextField(
                          controller: taskController,
                          autofocus: true,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter task title",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pomodoro Stepper
                      Row(
                        children: [
                          Text(
                            "Pomodoro Sessions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              setStateBottomSheet(() {
                                if (newPomodoros > 0) newPomodoros--;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: fieldColor,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.remove, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "$newPomodoros",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setStateBottomSheet(() {
                                if (newPomodoros < 99) newPomodoros++;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: fieldColor,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, size: 20),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Add/Save button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            final taskText = taskController.text.trim();
                            if (taskText.isNotEmpty) {
                              setState(() {
                                if (task == null) {
                                  _tasks.add({
                                    'title': taskText,
                                    'done': false,
                                    'pomodoros': newPomodoros,
                                    'donePomodoros': 0,
                                  });
                                } else {
                                  _tasks[index!] = {
                                    'title': taskText,
                                    'done': task['done'],
                                    'pomodoros': newPomodoros,
                                    'donePomodoros': task['donePomodoros'] ?? 0,
                                  };
                                }
                              });
                              Navigator.pop(context);
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            task == null ? "Add Task" : "Save",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

  String _currentMonth() {
    if (_weeks.isEmpty) return '';
    final currentWeek = _weeks[_currentWeekIndex];
    return DateFormat('MMMM').format(currentWeek[0]);
  }

  @override
  Widget build(BuildContext context) {
    if (_weeks.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                  _currentMonth(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
              Text(
                DateFormat('EEE d, yyyy').format(_selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Week horizontal scroll
                SizedBox(
                  height: 80,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.95),
                    itemCount: _weeks.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentWeekIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final week = _weeks[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: week.map((day) {
                          final isSelected =
                              day.day == _selectedDate.day &&
                                  day.month == _selectedDate.month;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = day;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEEE')
                                      .format(day)
                                      .substring(0, 1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? ctaColor
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ctaColor
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? (ThemeData
                                                      .estimateBrightnessForColor(
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color!,
                                                  ) ==
                                                  Brightness.dark
                                              ? lightAppBackground
                                              : darkAppBackground)
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                // Task list
                Expanded(
                  child: _tasks.isEmpty
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10), // 👈 fixed margin here
                              child: Slidable(
                                key: Key(task['title'] + index.toString()),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.40,
                                  children: [
                                    // Edit button
                                    CustomSlidableAction(
                                      flex: 1,
                                      onPressed: (_) {
                                        _openTaskBottomSheet(
                                            task: task, index: index);
                                      },
                                      backgroundColor: ctaColor,
                                      foregroundColor: Colors.white,
                                      child: const Icon(Icons.edit,
                                          size: 25, color: Colors.white),
                                    ),
                                    CustomSlidableAction(
                                      flex: 1,
                                      onPressed: (_) {
                                        setState(() {
                                          _tasks.removeAt(index);
                                        });
                                      },
                                      backgroundColor:
                                          const Color.fromARGB(255, 252, 93, 93),
                                      foregroundColor: Colors.white,
                                      child: const Icon(Icons.delete,
                                          size: 25, color: Colors.white),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 23,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? const Color.fromARGB(
                                            255, 243, 243, 243)
                                        : Colors.grey[850],
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(12),
                                      right: Radius.circular(0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Done button
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            task['done'] =
                                                !(task['done'] as bool);
                                          });
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: task['done']
                                                  ? Colors.transparent
                                                  : Theme.of(context).hintColor,
                                              width: 1,
                                            ),
                                            color: task['done']
                                                ? ctaColor
                                                : Colors.transparent,
                                          ),
                                          child: task['done']
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 16,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // Task title
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task['title'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: task['done']
                                                    ? Theme.of(context).hintColor
                                                    : Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? darkAppBackground
                                                        : lightAppBackground,
                                                decoration: task['done']
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                            if (task['pomodoros'] > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  "${task['donePomodoros']}/${task['pomodoros']} sessions completed",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
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
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Add Task button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              child: GestureDetector(
                onTap: _openTaskBottomSheet,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ctaColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
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
