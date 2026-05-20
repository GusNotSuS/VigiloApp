import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/settings_screen.dart';
import 'services/app_config.dart';
import 'package:flutter/services.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Envia o IP para o Android antes de rodar o layout
  const channel = MethodChannel('com.example.fitness/notifications');
  try {
    await channel.invokeMethod('updateIp', {'ip': AppConfig.serverIp});
  } catch (e) {
    print("Erro ao passar IP para o nativo: $e");
  }

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