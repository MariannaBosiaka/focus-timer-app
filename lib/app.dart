import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/timer/logic/timer_controller.dart';
import 'features/timer/ui/pages/timer_page.dart';
import 'features/timer/logic/theme_provider.dart';
import 'features/timer/logic/task_provider.dart';
import 'themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerController()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pomodoro App',
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            home: const TimerPage(),
          );
        },
      ),
    );
  }
}
