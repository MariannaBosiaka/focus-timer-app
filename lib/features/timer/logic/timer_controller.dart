import 'dart:async';
import 'package:flutter/material.dart';

class TimerController extends ChangeNotifier {
  int _initialSeconds = 1500;
  int _remainingSeconds = 1500;
  Timer? _timer;
  bool _isRunning = false;

  int get remainingSeconds => _remainingSeconds;
  int get initialSeconds => _initialSeconds;
  bool get isRunning => _isRunning;

  void start() {
    if (_isRunning) return;

    _isRunning = true;
    notifyListeners();

    _tick();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
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

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = _initialSeconds;
    notifyListeners();
  }

  void setDuration(Duration duration) {
    _initialSeconds = duration.inSeconds;
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
