import '../models/message_model.dart';
import '../services/message_service.dart';

class MessagesController {
  List<MessageModel> messages = [];

  void load() {
    messages = MessageService.getMessages();
  }
}