import '../models/message_model.dart';

class MessageService {
  static List<MessageModel> getMessages() {
    return [
      MessageModel(
        title: "Banco XP",
        body: "Seu acesso foi bloqueado, clique aqui",
      ),
      MessageModel(
        title: "Promoção",
        body: "Você ganhou um prêmio!",
      ),
    ];
  }
}