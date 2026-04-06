import 'dart:async';
import 'package:flutter/services.dart';
import '../models/message_model.dart';

class NativeMessageBridge {
  static const EventChannel _eventChannel = EventChannel(
    'com.example.fitness/messages_stream',
  );

  static Stream<MessageModel> get messageStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final map = Map<String, dynamic>.from(event as Map);
      return MessageModel.fromJson(map);
    });
  }
}