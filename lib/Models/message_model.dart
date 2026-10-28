import 'package:flat_up/Models/chatUser.dart';

class MessageList {
  final bool success;
  final MessageData data;

  MessageList({required this.success, required this.data});

  factory MessageList.fromJson(Map<String, dynamic> json) => MessageList(
    success: json['success'] ?? false,
    data: MessageData.fromJson(json['data'] ?? {}),
  );
}

class MessageData {
  final int currentPage;
  final List<Message> messages;
  final int total;
  final int perPage;

  MessageData({
    required this.currentPage,
    required this.messages,
    required this.total,
    required this.perPage,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) => MessageData(
    currentPage: json['current_page'] ?? 1,
    messages: List<Message>.from(
      (json['data'] as List?)?.map((x) => Message.fromJson(x)) ?? [],
    ),
    total: json['total'] ?? 0,
    perPage: json['per_page'] ?? 30,
  );
}

class Message {
  final int id;
  final int conversationId;
  final int userId;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatUser? user;
  bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.user,
    this.isRead = false, // بشكل افتراضي غير مقروء
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
     id: json['id'] ?? 0,
      conversationId: int.tryParse(json['conversation_id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'sent',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      isRead: false,
      user: json['user'] != null ? ChatUser.fromJson(json['user']) : null,
    );
  }

  void markAsRead() {
    isRead = true;
  }

  Message copyWith({bool? isRead}) {
    return Message(
      id: id,
      conversationId: conversationId,
      userId: userId,
      message: message,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user,
      isRead: isRead ?? this.isRead,
    );
  }
}
