import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../themes/colors.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> _tasks = [];
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
      _tasks.add(task.trim());
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _addTaskDialog() {
    String newTask = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          "Add Task",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
          decoration: InputDecoration(
            hintText: "Enter task name",
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
          onChanged: (value) => newTask = value,
          onSubmitted: (_) {
            if (newTask.trim().isNotEmpty) {
              _addTask(newTask);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (newTask.trim().isNotEmpty) {
                _addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  List<List<DateTime>> _generateWeeks() {
    List<List<DateTime>> weeks = [];
    DateTime start = DateTime.now();

    // align start to previous Monday
    start = start.subtract(Duration(days: start.weekday - 1));

    for (int i = 0; i < 52; i++) { // 1 year of weeks
      List<DateTime> week = List.generate(7, (index) => start.add(Duration(days: index)));
      weeks.add(week);
      start = start.add(Duration(days: 7));
    }
    return weeks;
  }

  String _currentMonth() {
    if (_weeks.isEmpty) return '';
    final currentWeek = _weeks[_currentWeekIndex];
    // show month of the Monday of the week
    return DateFormat('MMMM').format(currentWeek[0]);
  }

  @override
  Widget build(BuildContext context) {
    if (_weeks.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                _currentMonth(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                        final isSelected = day.day == _selectedDate.day &&
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).textTheme.bodyLarge!.color
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? (ThemeData.estimateBrightnessForColor(
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .color!) ==
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _tasks[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Theme.of(context).colorScheme.error,
                                  onPressed: () => _removeTask(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Add Task button
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                onPressed: _addTaskDialog,
                icon: const Icon(
                  Icons.add,
                  size: 22,
                ),
                label: const Text(
                  "Add Task",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
