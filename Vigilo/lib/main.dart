import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VigilioApp());
}

class VigilioApp extends StatelessWidget {
  const VigilioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vigilio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/messages': (_) => const MessagesScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}