class AppEndpoints {  
  // الشات
  static const String conversations = '/conversations';
  static const String messages = '/messages'; // للتوافق مع الكود القديم
  
  // ملاحظة: APIs الفعلية هي:
  // GET /conversations
  // GET /conversations/{id}
  // POST /conversations
  // GET /conversations/{id}/messages
  // POST /conversations/{id}/messages
  
  static const String messageUnreadCount = '/messages/unread-count'; // إذا كان موجوداً
  static const String broadcastingAuth = '/broadcasting/auth';
}