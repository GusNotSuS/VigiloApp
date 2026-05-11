import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/Message_Service.dart';
import 'message_details_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _service = MessageService();
  final ScrollController _scrollController = ScrollController();

  // Estado para controle de paginação e performance (Cenário B)
  List<MessageModel> _messages = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchPage();
    
    // Listener para implementar Lazy Loading (MVP 2 - Otimização)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Busca mensagens de forma paginada para garantir escalabilidade
  Future<void> _fetchPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await _service.fetchMessages(page: _page);
      setState(() {
        _page++;
        _messages.addAll(newItems);
        // Se a API retornar menos itens que o limite, não há mais dados
        if (newItems.isEmpty || newItems.length < 20) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mensagens: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatus(MessageModel message) {
    if (message.isSafe == true) return 'Segura';
    if (message.isPhishing == true) return 'Phishing';
    if (message.hasSocialEngineering == true) return 'Engenharia social';
    return 'Sem classificação';
  }

  Color _getStatusColor(MessageModel message) {
    if (message.isSafe == true) return Colors.green.shade700;
    if (message.isPhishing == true) return Colors.red.shade700;
    if (message.hasSocialEngineering == true) return Colors.orange.shade700;
    return Colors.grey.shade700;
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
                // Header customizado
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
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset(
                            'assets/Return_Button.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Caixa de Entrada',
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Mensagens capturadas',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _messages.isEmpty && _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    setState(() {
                                      _messages.clear();
                                      _page = 1;
                                      _hasMore = true;
                                    });
                                    await _fetchPage();
                                  },
                                  child: ListView.separated(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(top: 4, bottom: 70),
                                    itemCount: _messages.length + (_hasMore ? 1 : 0),
                                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                                    itemBuilder: (_, index) {
                                      if (index == _messages.length) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }

                                      final msg = _messages[index];
                                      return _buildMessageItem(msg);
                                    },
                                  ),
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

  Widget _buildMessageItem(MessageModel msg) {
    final isUnsafe = msg.isSafe == false;

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
            color: const Color(0xFFD9D9D9),
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
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              // Alerta Educativo (Estratégia de Diferenciação)
              if (isUnsafe && msg.classificationReason != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Risco: ${msg.classificationReason}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getStatusColor(msg).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(msg)),
                ),
                child: Text(
                  _getStatus(msg),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(msg),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}