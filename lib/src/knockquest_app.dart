import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'features/home/home_shell.dart';

class KnockQuestApp extends StatelessWidget {
  const KnockQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F8A5F)),
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: theme,
      home: const HomeShell(),
    );
  }
}
