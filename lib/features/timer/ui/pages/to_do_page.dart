import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();

  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _tasks.add(_controller.text.trim());
    });
    _controller.clear();
    _focusNode.requestFocus();
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
        title: const Text("Add Task"),
        content: TextField(
          enableSuggestions: false,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter task name"),
          onChanged: (value) => newTask = value,
          onSubmitted: (_) {
            if (newTask.trim().isNotEmpty) {
              setState(() {
                _tasks.add(newTask.trim());
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newTask.trim().isNotEmpty) {
                setState(() {
                  _tasks.add(newTask.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // Generates a list of 30 days starting from today
  List<DateTime> _generateDays() {
    return List.generate(
      30,
      (index) => DateTime.now().add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays();
    String month = DateFormat('MMMM').format(DateTime.now());


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                month,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Today's To-Do List",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Horizontal days tabs
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.day == _selectedDate.day &&
                    day.month == _selectedDate.month;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day), // Mon, Tue...
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color.fromARGB(255, 91, 91, 91),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Add task input with circular + button on the left
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _addTaskDialog,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Add Task',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EditableText(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    cursorColor: Colors.blue,
                    backgroundCursorColor: Colors.transparent,
                    keyboardType: TextInputType.text,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    contextMenuBuilder: (context, editableTextState) {
                      // Disable Android floating toolbar
                      return Container();
                    },
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
              ],
            ),
          ),

          // Task list
          Expanded(
            child: _tasks.isEmpty
                ? const Center(
                    child: Text(
                      "No tasks yet. Add something!",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_tasks[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTask(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
