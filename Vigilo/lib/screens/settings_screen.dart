import 'package:flutter/material.dart';
import '../services/notification_permission_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool notificationsEnabled = true;
  double phishingPercentage = 80;

  final NotificationPermissionService _permissionService =
      NotificationPermissionService();

  bool _isCheckingPermission = true;
  bool _permissionGranted = false;

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
        const SnackBar(
          content: Text('Não foi possível abrir as configurações do Android.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Ative o acesso a notificações do Vigilio e volte para o app.',
        ),
      ),
    );
  }

  String _permissionStatusText() {
    if (_isCheckingPermission) {
      return 'Verificando permissão...';
    }

    if (_permissionGranted) {
      return 'Permissão de acesso às notificações: ativada.';
    }

    return 'Permissão de acesso às notificações: desativada.';
  }

  Color _permissionStatusColor() {
    if (_isCheckingPermission) {
      return Colors.black87;
    }

    return _permissionGranted ? Colors.green.shade700 : Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Background.png',
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
                        child: Image.asset(
                          'assets/banner.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/',
                              (route) => false,
                            );
                          },
                          icon: Image.asset(
                            'assets/Return_Button.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Configurações',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
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
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Deseja receber as notificações de captura em tempo real?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Switch(
                                    value: notificationsEnabled,
                                    activeColor: const Color(0xFF2E97F2),
                                    onChanged: (value) {
                                      setState(() {
                                        notificationsEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Porcentagem para notificação:',
                                style: TextStyle(fontSize: 13),
                              ),
                              Slider(
                                value: phishingPercentage,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                activeColor: const Color(0xFF2E97F2),
                                label: '${phishingPercentage.round()}%',
                                onChanged: (value) {
                                  setState(() {
                                    phishingPercentage = value;
                                  });
                                },
                              ),
                              Text(
                                'Isso define a partir de quantos porcento de chance de ser phishing você receberá a notificação alertando phishing, recomendamos acima dos 80%.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Permissões necessárias:',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _handleOpenPermissions,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E97F2),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: const Text('Permissões'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _permissionStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _permissionStatusColor(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Essa permissão é o que nos permite ler notificações recebidas no aparelho para identificar possíveis mensagens suspeitas.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Image.asset(
                          'assets/Fala_Config.png',
                          width: 170,
                          fit: BoxFit.contain,
                        ),
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