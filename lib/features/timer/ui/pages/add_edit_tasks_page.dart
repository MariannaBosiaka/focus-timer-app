import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../themes/colors.dart';
import '../../logic/task_provider.dart';

class AddEditTasksPage extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, dynamic>? task;
  final int? index;

  const AddEditTasksPage({
    super.key,
    required this.selectedDate,
    this.task,
    this.index,
  });

  @override
  State<AddEditTasksPage> createState() => _AddEditTasksPageState();
}

class _AddEditTasksPageState extends State<AddEditTasksPage> {
  late TextEditingController _taskController;
  late int _pomodoros;

  // Timer length fields
  int _focusLength = 25;
  int _shortBreak = 5;
  int _longBreak = 10;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task?['title'] ?? '');
    _pomodoros = widget.task?['pomodoros'] ?? 0;
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.task == null) {
      provider.addTask(widget.selectedDate, {
        'title': text,
        'done': false,
        'pomodoros': _pomodoros,
        'donePomodoros': 0,
        'focusLength': _focusLength,
        'shortBreak': _shortBreak,
        'longBreak': _longBreak,
      });
    } else {
      provider.updateTask(widget.selectedDate, widget.index!, {
        'title': text,
        'done': widget.task!['done'],
        'pomodoros': _pomodoros,
        'donePomodoros': widget.task!['donePomodoros'] ?? 0,
        'focusLength': _focusLength,
        'shortBreak': _shortBreak,
        'longBreak': _longBreak,
      });
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                isEditing ? 'Edit Task' : 'Add New Task',
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: darkAppBackground,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Title Field ---
            TextField(
              controller: _taskController,
              autofocus: true,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Enter task title",
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2.5),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color?.withAlpha(180),
                  fontSize: 16,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),

            const SizedBox(height: 20),

            // --- Description Field ---
            TextField(
              controller: TextEditingController(
                  text: widget.task?['description'] ?? ''),
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Enter task description",
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ctaColor, width: 2.5),
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color?.withAlpha(180),
                  fontSize: 16,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),

            const SizedBox(height: 25),

            // --- Timer Lengths Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimerStepper("Focus", _focusLength, _decrementFocus, _incrementFocus),
                _buildTimerStepper("Short Break", _shortBreak, _decrementShortBreak, _incrementShortBreak),
                _buildTimerStepper("Long Break", _longBreak, _decrementLongBreak, _incrementLongBreak),
              ],
            ),

            const SizedBox(height: 25),

            // --- Pomodoro Sessions Stepper ---
            Row(
              children: [
                Text(
                  "Pomodoro Sessions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(width: 20),
                _buildCircleButton(Icons.remove, () {
                  setState(() {
                    if (_pomodoros > 0) _pomodoros--;
                  });
                }),
                const SizedBox(width: 12),
                Text(
                  "$_pomodoros",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                _buildCircleButton(Icons.add, () {
                  setState(() {
                    if (_pomodoros < 99) _pomodoros++;
                  });
                }),
              ],
            ),

            const Spacer(),

            // --- Save Button ---
            Center(
              child: TextButton(
                onPressed: _saveTask,
                style: TextButton.styleFrom(
                  backgroundColor: ctaColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  isEditing ? "Save" : "Add Task",
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
    );
  }

  // --- Timer Stepper Widget ---
  Widget _buildTimerStepper(String label, int value, VoidCallback onDecrement,
      VoidCallback onIncrement) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCircleButton(Icons.remove, onDecrement),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "$value",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildCircleButton(Icons.add, onIncrement),
          ],
        ),
      ],
    );
  }

  // --- Reusable Circle Button with CTA Color ---
  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ctaColor, // CTA color
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }

  // --- Timer Increment/Decrement Functions ---
  void _incrementFocus() => setState(() => _focusLength += 5);
  void _decrementFocus() {
    if (_focusLength > 5) setState(() => _focusLength -= 5);
  }

  void _incrementShortBreak() => setState(() => _shortBreak += 5);
  void _decrementShortBreak() {
    if (_shortBreak > 5) setState(() => _shortBreak -= 5);
  }

  void _incrementLongBreak() => setState(() => _longBreak += 5);
  void _decrementLongBreak() {
    if (_longBreak > 5) setState(() => _longBreak -= 5);
  }
}
