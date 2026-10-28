import 'package:flat_up/Models/conversation_model.dart';
import 'package:flat_up/Models/message_model.dart';
import 'package:flat_up/Servicse/chat_api.dart';
import 'package:flat_up/Servicse/realtime_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatController extends GetxController {
  final ChatApi chatApi = ChatApi();
  final RealtimeService realtime = Get.find<RealtimeService>();

  // القوائم
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxList<Message> messages = <Message>[].obs;

  // ScrollControllers
  final ScrollController conversationsScroll = ScrollController();
  final ScrollController messagesScroll = ScrollController();

  // متغيرات حالة
  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxBool otherUserTyping = false.obs;

  // معلومات المستخدم
  int _currentConversationId = 0;
  int _currentUserId = 0;
  String _currentUserRole = 'tenant'; // tenant أو landlord

  int get userId => _currentUserId;
  String get userRole => _currentUserRole;

  @override
  void onInit() {
    super.onInit();
    _loadUserData().then((_) => loadConversations());
  }

  /// تحميل الـ userId و role من SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('id') ?? 0;
    _currentUserRole = prefs.getString('role') ?? 'tenant';
  }

  /// تحميل المحادثات
  Future<void> loadConversations({bool refresh = false}) async {
    try {
      isLoadingConversations.value = true;

      final result = await chatApi.getConversations();

      if (result != null && result.success) {
        // result.data.conversations عبارة عن List<Conversation>
        conversations.assignAll(result.data.conversations);
      } else {
        conversations.clear();
      }
    } catch (e) {
      print("❌ loadConversations error: $e");
      conversations.clear();
    } finally {
      isLoadingConversations.value = false;
    }
  }

  /// فتح محادثة معينة
  Future<void> openChat(int conversationId) async {
    _currentConversationId = conversationId;
    messages.clear();
    await loadMessages();

    // الاشتراك في القناة الحية إذا موجود
    if (realtime.isConnected.value) {
      realtime.subscribeToChat(conversationId);
    }
  }

  /// تحميل الرسائل لمحادثة معينة
  Future<void> loadMessages() async {
    if (_currentConversationId == 0) return;

    try {
      isLoadingMessages.value = true;

      final result = await chatApi.getMessages(_currentConversationId);

      if (result != null) {
        messages.assignAll(result);

        // تعليم الرسائل كمقروءة محليًا
        for (var i = 0; i < messages.length; i++) {
          if (messages[i].userId != _currentUserId) {
            messages[i] = messages[i].copyWith(isRead: true);

            // إرسال حدث القراءة للـ WebSocket
            realtime.sendReadEvent(_currentConversationId);
          }
        }
      } else {
        messages.clear();
      }
    } catch (e) {
      print("❌ loadMessages error: $e");
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// إرسال رسالة
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      isSending.value = true;

      final success = await chatApi.sendMessage(
        conversationId: _currentConversationId,
        message: text,
      );

      if (success) {
        // إعادة تحميل الرسائل
        await loadMessages();
        await loadConversations(refresh: true);

        // تمرير Scroll إلى الأسفل بعد الإرسال
        if (messagesScroll.hasClients) {
          messagesScroll.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }

        // إرسال الرسالة للـ WebSocket
        realtime.sendMessageEvent({
          'conversation_id': _currentConversationId,
          'user_id': _currentUserId,
          'message': text,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("❌ sendMessage error: $e");
    } finally {
      isSending.value = false;
    }
  }

  /// إنشاء محادثة جديدة أو الحصول على موجودة
  Future<int?> createOrOpenConversation(int otherUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdLogin = prefs.getInt('id') ?? 0;

     final landLordId = otherUserId;

      final conv = await chatApi.createConversation(
        landlordId: landLordId,
        tenantId: userIdLogin,
      );

      if (conv != null) {
        await loadConversations(refresh: true);
        return conv.id;
      }
    } catch (e) {
      print("❌ createOrOpenConversation error: $e");
    }
    return null;
  }
}
