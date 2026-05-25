import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_permission_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool notificationsEnabled = true;
  double phishingPercentage = 80;

  final NotificationPermissionService _permissionService = NotificationPermissionService();

  bool _isCheckingPermission = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettingsAndPermissions();
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

  Future<void> _loadSettingsAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      phishingPercentage = (prefs.getInt('phishing_percentage') ?? 80).toDouble();
    });
    await _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    setState(() {
      _isCheckingPermission = true;
    });

    final granted = await _permissionService.checkPermission();

    if (!mounted) return;

    setState(() {
      _permissionGranted = granted;
      _isCheckingPermission = false;
    });
  }

  Future<void> _handleOpenPermissions() async {
    final opened = await _permissionService.openSettings();

    if (!mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir as configurações do Android.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ative o acesso a notificações do Vigilio e volte para o app.')),
    );
  }

  String _permissionStatusText() {
    if (_isCheckingPermission) return 'Verificando permissão...';
    return _permissionGranted ? 'Permissão de acesso às notificações: ativada.' : 'Permissão de acesso às notificações: desativada.';
  }

  Color _permissionStatusColor(bool isDark) {
    if (_isCheckingPermission) return isDark ? Colors.white70 : Colors.black87;
    return _permissionGranted ? (isDark ? Colors.green.shade300 : Colors.green.shade700) : (isDark ? Colors.red.shade300 : Colors.red.shade700);
  }

  Future<void> _sendSettingsToNative() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('phishing_percentage', phishingPercentage.round());

    const channel = MethodChannel('com.example.fitness/notifications');
    try {
      await channel.invokeMethod('updateNotificationSettings', {
        'enabled': notificationsEnabled,
        'percentage': phishingPercentage.round(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar configurações no nativo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = VigilioApp.of(context);
    final isDark = appState?.darkModeEnabled ?? false;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark ? 'assets/backgroundb.png' : 'assets/Background.png',
              key: ValueKey<String>(isDark ? 'dark' : 'light'),
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset('assets/banner.png', fit: BoxFit.fill),
                      ),
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                          },
                          icon: Image.asset(
                            'assets/Return_Button.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Configurações',
                          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                        ),
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
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2E97F2) : const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Modo Escuro',
                                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Switch(
                                    value: isDark,
                                    activeThumbColor: Colors.black,
                                    activeTrackColor: Colors.white60,
                                    onChanged: (value) {
                                      setState(() {
                                        appState?.toggleDarkMode(value);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.black26),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Deseja receber as notificações de captura em tempo real?',
                                      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                                    ),
                                  ),
                                  Switch(
                                    value: notificationsEnabled,
                                    activeThumbColor: isDark ? Colors.black : const Color(0xFF2E97F2),
                                    onChanged: (value) {
                                      setState(() {
                                        notificationsEnabled = value;
                                      });
                                      _sendSettingsToNative();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Porcentagem para notificação:',
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                              ),
                              Slider(
                                value: phishingPercentage,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                activeColor: isDark ? Colors.black : const Color(0xFF2E97F2),
                                inactiveColor: isDark ? Colors.white38 : Colors.black12,
                                label: '${phishingPercentage.round()}%',
                                onChanged: (value) {
                                  setState(() {
                                    phishingPercentage = value;
                                  });
                                },
                                onChangeEnd: (value) {
                                  _sendSettingsToNative();
                                },
                              ),
                              Text(
                                'Isso define a partir de quantos porcento de chance de ser phishing você receberá a notificação alertando phishing, recomendamos acima dos 80%.',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade800),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Permissões necessárias:',
                                style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _handleOpenPermissions,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.black : const Color(0xFF2E97F2),
                                    foregroundColor: isDark ? Colors.white : Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  child: const Text('Permissões'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _permissionStatusText(),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _permissionStatusColor(isDark)),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Essa permissão é o que nos permite ler notificações recebidas no aparelho para identificar possíveis mensagens suspeitas.',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.grey.shade800),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Image.asset('assets/Fala_Config.png', width: 170, fit: BoxFit.contain),
                        const SizedBox(height: 16),
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