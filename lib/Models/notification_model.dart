
class NotificationList {
  final bool success;
  final String message;
  final List<NotificationItem> notifications; // ✅ أزلت ? لأنها required

  NotificationList({
    required this.success,
    required this.message,
    required this.notifications, // ✅ match with factory
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) => NotificationList(
    success: json["success"] ?? false,
    message: json["message"] ?? "",
    notifications: List<NotificationItem>.from(
        (json["data"] as List?)?.map((x) => NotificationItem.fromJson(x)) ?? []), // ✅ غيرت هنا
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(notifications.map((x) => x.toJson())), // ✅ عدلت هنا
  };

  // ✅ Getter إضافي إذا بدك توافق مع الاسم القديم
  List<NotificationItem> get data => notifications;
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final String relatedEntity;
  final int relatedEntityId;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedEntity,
    required this.relatedEntityId,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    message: json["message"] ?? "",
    type: json["type"] ?? "",
    relatedEntity: json["related_entity"] ?? "",
    relatedEntityId: json["related_entity_id"] ?? 0,
    payload: json["payload"] is Map<String, dynamic> 
        ? json["payload"] 
        : Map<String, dynamic>.from(json["payload"] ?? {}),
    isRead: json["is_read"] ?? false,
    createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toString()),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "message": message,
    "type": type,
    "related_entity": relatedEntity,
    "related_entity_id": relatedEntityId,
    "payload": payload,
    "is_read": isRead,
    "created_at": createdAt.toIso8601String(),
  };

  NotificationItem copyWith({
    bool? isRead,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      relatedEntity: relatedEntity,
      relatedEntityId: relatedEntityId,
      payload: payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}