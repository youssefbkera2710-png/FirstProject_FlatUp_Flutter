import 'package:flat_up/Models/message_model.dart';
import 'package:flat_up/Models/user_models.dart';

class ConversationList {
  final bool success;
  final ConversationData data;

  ConversationList({required this.success, required this.data});

  factory ConversationList.fromJson(Map<String, dynamic> json) {
    return ConversationList(
      success: json['success'] ?? false,
      data: ConversationData.fromJson(json['data'] ?? {}),
    );
  }
}

class ConversationData {
  final int currentPage;
  final List<Conversation> conversations;

  ConversationData({required this.currentPage, required this.conversations});
  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      currentPage: json['current_page'] ?? 1,
      conversations: List<Conversation>.from(
        (json['data'] as List? ?? []).map((x) => Conversation.fromJson(x)),
      ),
    );
  }
}

class Conversation {
  final int id;
  final int landlordId;
  final int tenantId;
  final UserModels? landlord;
  final UserModels? tenant;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.landlordId,
    required this.tenantId,
    this.landlord,
    this.tenant,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      landlordId: json['landlord_id'] is int
          ? json['landlord_id']
          : int.parse(json['landlord_id'].toString()),
      tenantId: json['tenant_id'] is int
          ? json['tenant_id']
          : int.parse(json['tenant_id'].toString()),
      landlord: json['landlord'] != null
          ? UserModels.fromJson(json['landlord'])
          : null,
      tenant: json['tenant'] != null
          ? UserModels.fromJson(json['tenant'])
          : null,
      lastMessageAt:
          DateTime.tryParse(json['last_message_at']?.toString() ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      messages: (json['messages'] as List? ?? [])
          .map((e) => Message.fromJson(e))
          .toList(),
    );
  }

  /// حساب عدد الرسائل غير المقروءة بالنسبة للمستخدم الحالي
  int unreadCount(int currentUserId) {
    return messages
        .where((msg) => msg.userId != currentUserId && !msg.isRead)
        .length;
  }

  /// تعليم كل الرسائل كمقروءة بالنسبة للمستخدم الحالي
  void markAllAsRead(int currentUserId) {
    for (var msg in messages) {
      if (msg.userId != currentUserId) {
        msg.markAsRead();
      }
    }
  }

  /// الحصول على المستخدم الآخر في المحادثة
  UserModels? getOtherUser(int currentUserId) {
    if (currentUserId == landlordId) return tenant;
    if (currentUserId == tenantId) return landlord;
    return null;
  }

  /// التحقق إذا المستخدم الحالي هو مستأجر
  bool isTenant(int userId) => userId == tenantId;

  /// التحقق إذا المستخدم الحالي هو مؤجر
  bool isLandlord(int userId) => userId == landlordId;
  Conversation copyWith({
    int? id,
    int? landlordId,
    int? tenantId,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      tenantId: tenantId ?? this.tenantId,
      landlord: landlord,
      tenant: tenant,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}
