import 'dart:async';
import 'package:flutter/material.dart';

class TimerController extends ChangeNotifier {
  // Default durations for each mode
  Duration _focusDuration = const Duration(minutes: 1);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);

  // Current timer state
  late Duration _currentDuration;
  late int _remainingSeconds;
  int _selectedMode = 0; // 0=Focus, 1=Short Break, 2=Long Break
  Timer? _timer;
  bool _isRunning = false;

  TimerController() {
    _currentDuration = _focusDuration;
    _remainingSeconds = _currentDuration.inSeconds;
  }

  int get remainingSeconds => _remainingSeconds;
  int get initialSeconds => _currentDuration.inSeconds;
  bool get isRunning => _isRunning;
  int get selectedMode => _selectedMode;

  Duration get focusDuration => _focusDuration;
  Duration get shortBreakDuration => _shortBreakDuration;
  Duration get longBreakDuration => _longBreakDuration;

  // Start timer
    void start({VoidCallback? onComplete}) {
    if (_isRunning) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        pause(); // stop timer
        if (onComplete != null) {
          onComplete(); // trigger callback
        }
      }
    });

    _isRunning = true;
    notifyListeners();
  } 


  void _tick() {
    if (_remainingSeconds > 0) {
      _remainingSeconds--;
    } else {
      _timer?.cancel();
      _isRunning = false;
    }
    notifyListeners();
  }

  // Pause
  void pause() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // Reset to current mode's starting duration
  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = _currentDuration.inSeconds;
    notifyListeners();
  }

  // Change the active mode and load its saved duration
  void setMode(int mode) {
    _selectedMode = mode;
    switch (mode) {
      case 0:
        _currentDuration = _focusDuration;
        break;
      case 1:
        _currentDuration = _shortBreakDuration;
        break;
      case 2:
        _currentDuration = _longBreakDuration;
        break;
    }
    _remainingSeconds = _currentDuration.inSeconds;
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Update the saved duration for a specific mode
  void updateDurationForMode(int mode, Duration duration) {
    if (mode == 0) _focusDuration = duration;
    if (mode == 1) _shortBreakDuration = duration;
    if (mode == 2) _longBreakDuration = duration;

    // If currently on this mode, update currentDuration too
    if (mode == _selectedMode) {
      _currentDuration = duration;
      _remainingSeconds = duration.inSeconds;
    }
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  // Set current duration without touching saved mode durations
  void setDuration(Duration duration) {
    _currentDuration = duration;
    _remainingSeconds = duration.inSeconds;
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
