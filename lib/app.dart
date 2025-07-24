import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/timer/logic/timer_controller.dart';
import 'features/timer/ui/pages/timer_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerController(),
      child: MaterialApp(
        title: 'Pomodoro App',
        theme: ThemeData(primarySwatch: Colors.red),
        home: const TimerPage(),
      ),
    );
  }
}