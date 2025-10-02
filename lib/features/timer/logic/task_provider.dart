import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskProvider extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _tasksByDate = {};

  // Store selected date (default: today)
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get tasks for specific date
  List<Map<String, dynamic>> getTasksForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _tasksByDate[key] ?? [];
  }

  // Get tasks for the currently selected date
  List<Map<String, dynamic>> get tasksForSelectedDate {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _tasksByDate[key] ?? [];
  }

  // Add task
  void addTask(DateTime date, Map<String, dynamic> task) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (!_tasksByDate.containsKey(key)) {
      _tasksByDate[key] = [];
    }
    _tasksByDate[key]!.add(task);
    notifyListeners();
  }

  // Update task
  void updateTask(DateTime date, int index, Map<String, dynamic> updatedTask) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (_tasksByDate.containsKey(key)) {
      _tasksByDate[key]![index] = updatedTask;
      notifyListeners();
    }
  }

  // Remove task
  void removeTask(DateTime date, int index) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (_tasksByDate.containsKey(key)) {
      _tasksByDate[key]!.removeAt(index);
      notifyListeners();
    }
  }

  // Toggle done
  void toggleDone(DateTime date, int index) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    if (_tasksByDate.containsKey(key)) {
      _tasksByDate[key]![index]['done'] =
          !(_tasksByDate[key]![index]['done'] as bool);
      notifyListeners();
    }
  }

  // Increment donePomodoros for a task by index
  void incrementPomodoro(DateTime date, int index) {
    final key = DateFormat('yyyy-MM-dd').format(date);

    if (_tasksByDate.containsKey(key)) {
      final task = _tasksByDate[key]![index];

      // Initialize if missing
      task['donePomodoros'] = (task['donePomodoros'] ?? 0) + 1;

      // Optional: Mark as done if all pomodoros completed
      if (task['donePomodoros'] >= (task['pomodoros'] ?? 0)) {
        task['done'] = true;
      }

      notifyListeners();
    }
  }

}

