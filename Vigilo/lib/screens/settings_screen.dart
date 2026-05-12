import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool notificationsEnabled = true;
  double phishingPercentage = 80;
  bool _isCheckingPermission = true;
  bool _permissionGranted = false;

  final NotificationPermissionService _permissionService = NotificationPermissionService();
  static const _channel = MethodChannel('com.example.fitness/notifications');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPermissionStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPermissionStatus();
    }
  }

  Future<void> _loadPermissionStatus() async {
    setState(() => _isCheckingPermission = true);
    final granted = await _permissionService.checkPermission();
    if (!mounted) return;
    setState(() {
      _permissionGranted = granted;
      _isCheckingPermission = false;
    });
  }

  Future<void> _updateNotificationConfigs() async {
    try {
      await _channel.invokeMethod('updateConfigs', {
        'enabled': notificationsEnabled,
        'minRiskScore': phishingPercentage / 100,
      });
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<void> _handleOpenPermissions() async {
    final opened = await _permissionService.openSettings();
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir as configurações.')),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/Background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: Stack(
                    children: [
                      Positioned.fill(child: Image.asset('assets/banner.png', fit: BoxFit.fill)),
                      Positioned(
                        left: 8, top: 0, bottom: 0,
                        child: IconButton(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                          icon: Image.asset('assets/Return_Button.png', width: 24, height: 24),
                        ),
                      ),
                      const Center(
                        child: Text('Configurações', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: Text('Deseja receber as notificações?', style: TextStyle(fontSize: 13))),
                                  Switch(
                                    value: notificationsEnabled,
                                    activeColor: const Color(0xFF2E97F2),
                                    onChanged: (value) {
                                      setState(() => notificationsEnabled = value);
                                      _updateNotificationConfigs();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Porcentagem para notificação: ${phishingPercentage.round()}%', style: const TextStyle(fontSize: 13)),
                              Slider(
                                value: phishingPercentage,
                                min: 0, max: 100, divisions: 20,
                                activeColor: const Color(0xFF2E97F2),
                                onChanged: (value) {
                                  setState(() => phishingPercentage = value);
                                  _updateNotificationConfigs();
                                },
                              ),
                              const SizedBox(height: 16),
                              const Text('Permissões necessárias:', style: TextStyle(fontSize: 13)),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleOpenPermissions,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E97F2)),
                                  child: const Text('Configurar Permissões', style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}