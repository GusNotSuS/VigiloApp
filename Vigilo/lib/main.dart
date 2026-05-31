import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'screens/home_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  
  String? deviceId = prefs.getString('device_id');
  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }

  final bool isDark = prefs.getBool('dark_mode') ?? false;
  final String serverIp = prefs.getString('server_ip') ?? '10.115.245.25';

  const channel = MethodChannel('com.example.fitness/notifications');
  try {
    await channel.invokeMethod('updateIp', {'ip': serverIp});
    await channel.invokeMethod('updateDeviceId', {'deviceId': deviceId});
  } catch (e) {
    debugPrint("Erro ao sincronizar dados com o nativo: $e");
  }

  runApp(VigilioApp(initialDarkMode: isDark));
}

class VigilioApp extends StatefulWidget {
  final bool initialDarkMode;
  const VigilioApp({super.key, required this.initialDarkMode});

  static _VigilioAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_VigilioAppState>();

  @override
  State<VigilioApp> createState() => _VigilioAppState();
}

class _VigilioAppState extends State<VigilioApp> {
  late bool _darkModeEnabled;

  bool get darkModeEnabled => _darkModeEnabled;

  void toggleDarkMode(bool value) async {
    setState(() {
      _darkModeEnabled = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = widget.initialDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vigilio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: _darkModeEnabled ? const Color(0xFF121212) : Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}