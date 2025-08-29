import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../themes/colors.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<Map<String, dynamic>> _tasks = []; // title + done + time
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

  void _addTask(String task) {
    if (task.trim().isEmpty) return;
    setState(() {
      _tasks.add({
        'title': task.trim(),
        'done': false,
        'time': null, // planned time (can be edited later)
      });
    });
  }

  void _editTaskDialog(int index) {
    String updatedTitle = _tasks[index]['title'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            "Edit Task",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextField(
                controller: TextEditingController(text: updatedTitle),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                decoration: InputDecoration(
                  labelText: "Task",
                  labelStyle: TextStyle(color: Theme.of(context).hintColor),
                ),
                onChanged: (value) => updatedTitle = value,
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

    void _addTaskBottomSheet() {
    final TextEditingController taskController = TextEditingController();
    int newPomodoros = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (context) {
        final fieldColor = Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 243, 243, 243)
            : Colors.grey[850];

        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return FractionallySizedBox(
              heightFactor: 0.7,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add New Task",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Task Title
                      Text(
                        "Task Title",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.light
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
                            hintText: "Enter task name",
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pomodoro Stepper in the same row as title
                      Row(
                        children: [
                          Text(
                            "Pomodoro Sessions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Minus button
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
                          // Current number
                          Text(
                            "$newPomodoros",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          // Plus button
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

                      // Centered Add Task button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            final taskText = taskController.text.trim();
                            if (taskText.isNotEmpty) {
                              // Update main page state
                              setState(() {
                                _tasks.add({
                                  'title': taskText,
                                  'done': false,
                                  'pomodoros': newPomodoros,
                                  'donePomodoros': 0,
                                });
                              });
                              Navigator.pop(context); // close bottom sheet
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
                          child: const Text(
                            "Add Task",
                            style: TextStyle(
                              fontSize: 17,
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

    // align start to previous Monday
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
                        children:
                            week.map((day) {
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
                                      DateFormat('E').format(day)[0],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge!.color
                                                : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? (ThemeData.estimateBrightnessForColor(
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color!,
                                                          ) ==
                                                          Brightness.dark
                                                      ? lightAppBackground
                                                      : darkAppBackground)
                                                  : Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge!.color,
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
                  child:
                      _tasks.isEmpty
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
                              return Dismissible(
                                key: Key(task['title'] + index.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  setState(() {
                                    _tasks.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Task deleted"),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 23,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? const Color.fromARGB(
                                              255,
                                              243,
                                              243,
                                              243,
                                            )
                                            : Colors.grey[850],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      // Circular button for done/undone
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            task['done'] =
                                                !(task['done'] as bool);
                                          });
                                        },
                                        child: Container(
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Theme.of(context).hintColor,
                                              width: 1,
                                            ),
                                            color:
                                                task['done']
                                                    ? Theme.of(
                                                      context,
                                                    ).textTheme.bodyLarge!.color
                                                    : Colors.transparent,
                                          ),
                                          child:
                                              task['done']
                                                  ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                  : null,
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // Task title + planned time
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
                                                color:
                                                  task['done']
                                                      ? Theme.of(context).hintColor
                                                      :
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.light
                                                        ? darkAppBackground
                                                        : lightAppBackground,
                                                decoration:
                                                    task['done']
                                                        ? TextDecoration
                                                            .lineThrough
                                                        : TextDecoration.none,
                                              ),
                                            ),
                                            if (task['pomodoros'] > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  "${task['donePomodoros']}/${task['pomodoros']} sessions completed",
                                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Three-dot menu
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editTaskDialog(index);
                                          }
                                        },
                                        itemBuilder:
                                            (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 18),
                                                    SizedBox(width: 8),
                                                    Text("Edit"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                      ),
                                    ],
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
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: _addTaskBottomSheet,
                icon: const Icon(Icons.add, size: 22),
                label: const Text(
                  "Add Task",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
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
