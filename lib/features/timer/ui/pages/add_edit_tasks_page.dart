import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../themes/colors.dart';
import '../../logic/task_provider.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late TextEditingController _descriptionController;
  late int _pomodoros;
  String _selectedSymbol = '-';

  // Timer lengths
  int _focusLength = 25;
  int _shortBreak = 5;
  int _longBreak = 10;

  // --- Category Selection ---
  final List<String> _categories = [
    "Study",
    "Chores",
    "Meeting",
    "Work",
    "Hobby",
    "Exercise",
    "Reading",
    "Other",
  ];

  String? _selectedCategory;

  final FocusNode _customNumberFocusNode = FocusNode();

  // Selected mode
  String _selectedMode = "Focus";

  final List<String> _modes = ["Focus", "Short Break", "Long Break"];
  final TextEditingController _customNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task?['title'] ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?['description'] ?? '',
    );
    _pomodoros = widget.task?['pomodoros'] ?? 0;

    if (_pomodoros > 0 && _pomodoros <= 4) {
      _selectedSymbol = _pomodoros.toString();
    } else if (_pomodoros > 4) {
      _selectedSymbol = 'custom';
      _customNumberController.text = _pomodoros.toString();
    } else {
      _selectedSymbol = '-';
    }

    _customNumberFocusNode.addListener(() {
      setState(() {}); // rebuild when focus changes
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    _customNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
  final text = _taskController.text.trim();
  if (text.isEmpty) return;

  final provider = Provider.of<TaskProvider>(context, listen: false);

  int selectedPomodoros = 0;
  if (_selectedSymbol == 'custom' && _customNumberController.text.isNotEmpty) {
    selectedPomodoros = int.tryParse(_customNumberController.text) ?? 0;
  } else if (_selectedSymbol != '-' && _selectedSymbol != 'custom') {
    selectedPomodoros = int.tryParse(_selectedSymbol) ?? 0;
  }

  _pomodoros = selectedPomodoros;

  final taskData = {
    'title': text,
    'description': _descriptionController.text.trim(),
    'done': widget.task?['done'] ?? false,
    'pomodoros': _pomodoros,
    'donePomodoros': widget.task?['donePomodoros'] ?? 0,
    'focusLength': _focusLength,
    'shortBreak': _shortBreak,
    'longBreak': _longBreak,
    'category': _selectedCategory ?? '',
  };

  try {
    if (widget.task == null || widget.task!['id'] == null) {
      // New task → add via provider
      await provider.addTask(widget.selectedDate, {
        ...taskData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Existing task → update via provider
      final taskId = widget.task!['id'];
      await provider.updateTask(widget.selectedDate, widget.index!, {
        ...taskData,
        'id': taskId,
      });
    }

    Navigator.pop(context);
  } catch (e) {
    print("Error saving task: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save task. Try again.')),
    );
  }
}


  int get _currentValue {
    switch (_selectedMode) {
      case "Short Break":
        return _shortBreak;
      case "Long Break":
        return _longBreak;
      default:
        return _focusLength;
    }
  }

  void _setCurrentValue(int newValue) {
    setState(() {
      switch (_selectedMode) {
        case "Short Break":
          _shortBreak = newValue;
          break;
        case "Long Break":
          _longBreak = newValue;
          break;
        default:
          _focusLength = newValue;
      }
    });
  }

  void _increment() => _setCurrentValue(_currentValue + 5);
  void _decrement() {
    if (_currentValue > 5) _setCurrentValue(_currentValue - 5);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 180,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Split the title into two lines
                  Text(
                    isEditing ? 'Edit' : 'Create',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: yellowTextColor,
                    ),
                  ),
                  Text(
                    'Task',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: yellowTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              40,
              MediaQuery.of(context).size.height *
                  0.1, // responsive top padding
              40,
              MediaQuery.of(context).size.height *
                  0.335, // bottom padding for button
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Title Field ---
                _labeledTextField(
                  label: "Task Title",
                  hint: "Enter task title",
                  controller: _taskController,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // --- Focus Sessions Label ---
                Text(
                  "Focus Sessions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: purpleCtaColor,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                // --- Symbol Squares Row ---
                Row(
                  children: [
                    // --- Symbol Boxes ('-', '1', '2', '3', '4') ---
                    ...['-', '1', '2', '3', '4'].map((symbol) {
                      final isSelected = _selectedSymbol == symbol;

                      return GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _selectedSymbol = symbol;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.02,
                          ),
                          width: MediaQuery.of(context).size.width * 0.08,
                          height: MediaQuery.of(context).size.width * 0.08,
                          decoration: BoxDecoration(
                            color: isSelected ? ctaColor : purpleCtaColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              symbol,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? darkAppBackground
                                        : yellowTextColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),

                    // --- "+ add" text ---
                    Text(
                      "+ add",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: yellowTextColor,
                      ),
                    ),

                    SizedBox(width: MediaQuery.of(context).size.width * 0.02),

                    // --- Custom number box (acts as 6th selectable box) ---
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                      height: MediaQuery.of(context).size.width * 0.08,
                      child: Focus(
                        focusNode: _customNumberFocusNode,
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            setState(() {
                              _selectedSymbol = 'custom';
                            });
                          } else {
                            if (_selectedSymbol == 'custom') {
                              setState(() {});
                            }
                          }
                        },
                        child: TextField(
                          controller: _customNumberController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                (_customNumberFocusNode.hasFocus ||
                                        _selectedSymbol == 'custom')
                                    ? darkAppBackground
                                    : yellowTextColor,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor:
                                (_customNumberFocusNode.hasFocus ||
                                        _selectedSymbol == 'custom')
                                    ? ctaColor
                                    : purpleCtaColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^([1-9][0-9]?|0)$'),
                            ), // 0–99
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSymbol = 'custom';
                            });
                          },
                          onTap: () {
                            setState(() {
                              _selectedSymbol = 'custom';
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // --- Description Field ---
                _labeledTextField(
                  label: "Notes",
                  hint: "Enter task description",
                  controller: _descriptionController,
                  minLines: 1,
                  maxLines: null,
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                // --- Categories Section ---
                Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: purpleCtaColor,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                Wrap(
                  spacing:
                      MediaQuery.of(context).size.width *
                      0.03, // horizontal spacing
                  runSpacing:
                      MediaQuery.of(context).size.height *
                      0.015, // vertical spacing
                  children:
                      _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = isSelected ? null : category;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.012,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.07,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? ctaColor : purpleCtaColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? darkAppBackground
                                        : yellowTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // --- Floating Save/Create Button ---
          Positioned(
            left: 0,
            right: 0,
            bottom:
                MediaQuery.of(context).size.height * 0.02, // responsive bottom
            child: Center(
              child: SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.7, // responsive button width
                child: TextButton(
                  onPressed: _saveTask,
                  style: TextButton.styleFrom(
                    backgroundColor: ctaColor,
                    padding: EdgeInsets.symmetric(
                      vertical:
                          MediaQuery.of(context).size.height *
                          0.018, // responsive vertical padding
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    isEditing ? "Save" : "Create New Task",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Labeled TextField (with solid color) ---
  Widget _labeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: purpleCtaColor,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            color: yellowTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: purpleCtaColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: purpleCtaColor, width: 1),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: purpleCtaColor),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}
