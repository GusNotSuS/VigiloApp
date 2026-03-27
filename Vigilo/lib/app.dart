import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/messages/screens/messages_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.dashboard,
      routes: {
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.messages: (_) => const MessagesScreen(),
      },
    );
  }
}