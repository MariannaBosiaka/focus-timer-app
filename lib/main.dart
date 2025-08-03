import 'package:flutter/material.dart';
import 'package:focus_timer_app/app.dart';
import 'package:flutter/services.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  // Full immersive mode: hides status and nav bars (including icons)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}