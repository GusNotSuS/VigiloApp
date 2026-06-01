import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../services/Message_Service.dart';
import '../main.dart';
import 'message_details_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _service = MessageService();
  late Future<List<MessageModel>> _futureMessages;
  int _riskLimit = 80;

  @override
  void initState() {
    super.initState();
    _futureMessages = _loadAndFilterMessages();
  }

  Future<void> _refreshMessages() async {
    setState(() {
      _futureMessages = _loadAndFilterMessages();
    });
  }

  Future<List<MessageModel>> _loadAndFilterMessages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Recupera o valor salvo nas configurações (ex: 80)
      _riskLimit = prefs.getInt('phishing_percentage') ?? 80;
    });

    final allMessages = await _service.fetchMessages();

    // FILTRO INTELIGENTE: Respeita a porcentagem dinâmica das configurações
    return allMessages.where((msg) {
      // Converte o score decimal do banco (ex: 0.85) para escala de 0 a 100 (ex: 85)
      final int calculatedScore = (msg.riskScore * 100).round();
      
      // Condição 1: A mensagem precisa ser classificada como ameaça (Phishing ou Engenharia Social)
      final bool isThreat = msg.isPhishing == true || msg.hasSocialEngineering == true || msg.isSafe == false;
      
      // Condição 2: O score calculado precisa ser maior ou igual ao limite definido pelo usuário
      final bool matchesRiskLimit = calculatedScore >= _riskLimit;

      // Só exibe o card se cumprir os dois requisitos
      return isThreat && matchesRiskLimit;
    }).toList();
  }

  String _getStatus(MessageModel message) {
    if (message.isSafe == true) return 'Segura';
    if (message.isPhishing == true) return 'Phishing';
    if (message.hasSocialEngineering == true) return 'Engenharia social';
    return 'Suspeita';
  }

  Color _getStatusColor(MessageModel message, bool isDark) {
    if (message.isSafe == true) return isDark ? Colors.green.shade300 : Colors.green.shade700;
    if (message.isPhishing == true) return isDark ? Colors.red.shade300 : Colors.red.shade700;
    if (message.hasSocialEngineering == true) return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
    return isDark ? Colors.amber.shade300 : Colors.amber.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = VigilioApp.of(context)?.darkModeEnabled ?? false;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark ? 'assets/backgroundb.png' : 'assets/Background.png',
              key: ValueKey<bool>(isDark),
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
                          'Caixa de Entrada',
                          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Configuração de Alerta Ativa: $_riskLimit%',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _refreshMessages,
                                child: FutureBuilder<List<MessageModel>>(
                                  future: _futureMessages,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }

                                    // Se houver qualquer erro de conversão, ele será impresso na tela do celular
                                    if (snapshot.hasError) {
                                      return ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Text(
                                                'Erro ao processar banco de dados:\n${snapshot.error}', 
                                                style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    final messages = snapshot.data ?? [];

                                    if (messages.isEmpty) {
                                      return ListView(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        children: [
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                                          Center(
                                            child: Text(
                                              'Nenhuma mensagem suspeita encontrada.', 
                                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return ListView.separated(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(top: 4, bottom: 70),
                                      itemCount: messages.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                                      itemBuilder: (_, index) {
                                        final msg = messages[index];
                                        final statusColor = _getStatusColor(msg, isDark);

                                        return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(6),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MessageDetailsScreen(message: msg),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF2E97F2) : const Color(0xFFD9D9D9),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.black12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    msg.content,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: statusColor.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(20),
                                                      border: Border.all(color: statusColor),
                                                    ),
                                                    child: Text(
                                                      '${_getStatus(msg)} (${(msg.riskScore * 100).round()}%)',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 6,
                          bottom: 8,
                          child: Image.asset(
                            'assets/icon.png',
                            width: 46,
                            height: 46,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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