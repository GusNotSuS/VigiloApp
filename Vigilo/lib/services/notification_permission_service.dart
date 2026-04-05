import 'package:flutter/services.dart';

class NotificationPermissionService {
  static const MethodChannel _channel =
      MethodChannel('com.example.fitness/notifications');

  Future<bool> checkPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> openSettings() async {
    try {
      final result = await _channel.invokeMethod<bool>('openSettings');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}