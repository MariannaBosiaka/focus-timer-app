import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, List<Map<String, dynamic>>> _tasksByDate = {};

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String? _selectedTaskTitle;
  String? get selectedTaskTitle => _selectedTaskTitle;

  void setSelectedTaskTitle(String? title) {
    _selectedTaskTitle = title;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchTasksForDate(date); // fetch from Firestore when date changes
    notifyListeners();
  }

  List<Map<String, dynamic>> getTasksForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _tasksByDate[key] ?? [];
  }

  List<Map<String, dynamic>> get tasksForSelectedDate {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _tasksByDate[key] ?? [];
  }

  // ✅ Firestore: Fetch tasks
  Future<void> fetchTasksForDate(DateTime date) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final snapshot = await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .orderBy('createdAt', descending: true)
        .get();

    _tasksByDate[key] = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // store doc ID for updates/deletes
      return data;
    }).toList();

    notifyListeners();
  }

  // ✅ Add task to Firestore
  Future<void> addTask(DateTime date, Map<String, dynamic> task) async {
    final key = DateFormat('yyyy-MM-dd').format(date);

    await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .add({
          ...task,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await fetchTasksForDate(date);
  }

  // ✅ Update task in Firestore
  Future<void> updateTask(DateTime date, int index, Map<String, dynamic> updatedTask) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final task = _tasksByDate[key]?[index];

    if (task == null || task['id'] == null) return;

    await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .doc(task['id'])
        .update(updatedTask);

    await fetchTasksForDate(date);
  }

  // ✅ Remove task from Firestore
  Future<void> removeTask(DateTime date, int index) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final task = _tasksByDate[key]?[index];

    if (task == null || task['id'] == null) return;

    await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .doc(task['id'])
        .delete();

    await fetchTasksForDate(date);
  }

  // ✅ Toggle done (Firestore update)
  Future<void> toggleDone(DateTime date, int index) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final task = _tasksByDate[key]?[index];
    if (task == null || task['id'] == null) return;

    final newDone = !(task['done'] ?? false);

    await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .doc(task['id'])
        .update({'done': newDone});

    await fetchTasksForDate(date);
  }

  // ✅ Increment Pomodoro count
  Future<void> incrementPomodoro(DateTime date, int index) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final task = _tasksByDate[key]?[index];
    if (task == null || task['id'] == null) return;

    int donePomodoros = (task['donePomodoros'] ?? 0) + 1;
    bool isDone = donePomodoros >= (task['pomodoros'] ?? 0);

    await _firestore
        .collection('tasks')
        .doc(key)
        .collection('userTasks')
        .doc(task['id'])
        .update({
          'donePomodoros': donePomodoros,
          'done': isDone,
        });

    await fetchTasksForDate(date);
  }
}
