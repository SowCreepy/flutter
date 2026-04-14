import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_client.dart';
import 'auth_service.dart';

class SocketService extends ChangeNotifier {
  static final SocketService instance = SocketService._();
  SocketService._();

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  final _invitationReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _invitationAcceptedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _invitationRejectedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _chatMessageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onInvitationReceived =>
      _invitationReceivedController.stream;
  Stream<Map<String, dynamic>> get onInvitationAccepted =>
      _invitationAcceptedController.stream;
  Stream<Map<String, dynamic>> get onInvitationRejected =>
      _invitationRejectedController.stream;
  Stream<Map<String, dynamic>> get onChatMessage =>
      _chatMessageController.stream;

  void connect() {
    final token = AuthService.instance.accessToken;
    if (token == null) return;

    disconnect();

    final baseUrl = ApiClient.baseUrl.replaceAll('/api', '');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('[Socket] Connected');
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('[Socket] Disconnected');
      notifyListeners();
    });

    _socket!.on('invitation:received', (data) {
      _invitationReceivedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('invitation:accepted', (data) {
      _invitationAcceptedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('invitation:rejected', (data) {
      _invitationRejectedController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('chat:message', (data) {
      _chatMessageController.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('error', (data) {
      debugPrint('[Socket] Error: $data');
    });

    _socket!.connect();
  }

  void joinChat(String chatId) {
    _socket?.emit('chat:join', {'chatId': chatId});
  }

  void sendMessage(String chatId, String content) {
    _socket?.emit('chat:send', {'chatId': chatId, 'content': content});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    notifyListeners();
  }

  void dispose() {
    disconnect();
    _invitationReceivedController.close();
    _invitationAcceptedController.close();
    _invitationRejectedController.close();
    _chatMessageController.close();
    super.dispose();
  }
}
