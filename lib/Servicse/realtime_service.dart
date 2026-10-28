import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flat_up/Helper/user_info.dart';
import 'package:flat_up/Helper/apiService.dart';
import 'package:flat_up/constants/app_endpoints.dart';

class RealtimeService extends GetxService {
  IOWebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final RxBool isConnected = false.obs;
  final RxBool isSubscribed = false.obs;
  String? socketId;
  int _reconnectAttempts = 0;
  bool _manualDisconnect = false;

  int? _currentConversationId;

  Function(Map<String, dynamic>)? onNewMessage;

  Future<void> connectToChat(int conversationId) async {
    _currentConversationId = conversationId;

    disconnect();
    _manualDisconnect = false;

    final url =
        'wss://ws-eu.pusher.com/app/a73d588a7c7b5a407642?protocol=7&client=flutter&version=1.0';

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
    } catch (e) {
      print('❌ WebSocket connection error: $e');
      _reconnect();
    }
  }

  void _handleMessage(dynamic raw) {
    try {
      final payload = jsonDecode(raw);
      final event = payload['event'];

      if (event == 'pusher:ping') {
        _channel?.sink.add(jsonEncode({'event': 'pusher:pong'}));
        return;
      }

      if (event == 'pusher:connection_established') {
        final data = jsonDecode(payload['data']);
        socketId = data['socket_id'];
        isConnected.value = true;
        _reconnectAttempts = 0;

        if (_currentConversationId != null) {
          subscribeToChat(_currentConversationId!);
        }
        return;
      }

      final channel = payload['channel'];
      if (channel?.contains('private-chat.') ?? false) {
        final rawData = payload['data'];
        final data = rawData is String ? jsonDecode(rawData) : rawData;

        if (event == 'chat.message') {
          onNewMessage?.call(data);
        }
      }
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
    }
  }

  void sendReadEvent(int conversationId) {
    if (!isConnected.value || socketId == null) {
      print('❌ Cannot send read event: WebSocket not connected');
      return;
    }

    try {
      final eventData = {
        'event': 'client-chat.read',
        'channel': 'private-chat.$conversationId',
        'data': jsonEncode({
          'conversation_id': conversationId,
          'user_id': UserInfo.id,
          'read_at': DateTime.now().toIso8601String(),
        }),
      };

      _channel?.sink.add(jsonEncode(eventData));
      print('👁️ Read event sent for conversation $conversationId');
    } catch (e) {
      print('❌ Error sending read event: $e');
    }
  }

  Future<void> subscribeToChat(int conversationId) async {
    if (socketId == null || !isConnected.value) return;

    final channelName = 'private-chat.$conversationId';
    try {
      await UserInfo.loadFromStorage();
      final apiService = ApiServiceImpl();

      // تمرير التوكن داخل headers
      final response = await apiService.post(
        subUrl: AppEndpoints.broadcastingAuth,
        data: {'channel_name': channelName, 'socket_id': socketId},
        headers: {'Authorization': 'Bearer ${UserInfo.token}'},
      );

      final body = jsonDecode(response.body);
      if (body['auth'] != null) {
        _channel?.sink.add(
          jsonEncode({
            'event': 'pusher:subscribe',
            'data': {'channel': channelName, 'auth': body['auth']},
          }),
        );
        isSubscribed.value = true;
        print('✅ Subscribed to $channelName');
      } else {
        print('❌ Auth failed: ${body['message']}');
      }
    } catch (e) {
      print('❌ Subscription error: $e');
    }
  }

  void sendMessageEvent(Map<String, dynamic> message) {
    if (!isConnected.value || socketId == null) return;

    final eventData = {
      'event': 'client-chat.message',
      'channel': 'private-chat.${message['conversation_id']}',
      'data': jsonEncode(message),
    };
    _channel?.sink.add(jsonEncode(eventData));
  }

  void _handleError(error) => _reconnect();

  void _handleDone() => _reconnect();

  void _reconnect() {
    if (_manualDisconnect) return;
    isConnected.value = false;
    isSubscribed.value = false;

    if (_reconnectAttempts >= 5) return;
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    Future.delayed(delay, () {
      if (_currentConversationId != null) {
        connectToChat(_currentConversationId!);
      }
    });
  }

  void disconnect() {
    _manualDisconnect = true;
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    socketId = null;
    isConnected.value = false;
    isSubscribed.value = false;
  }
}
