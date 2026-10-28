import 'package:flat_up/Models/conversation_model.dart';
import 'package:flat_up/Models/message_model.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/constants/app_endpoints.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApi {
  final Api api = Api();

  /// دالة داخلية لجلب البيانات الأساسية من التخزين
  /// ملاحظة: نمرر التوكن صافي لأن كلاس Api يضيف "Bearer " تلقائياً
  Future<Map<String, String>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final lang = prefs.getString('language') ?? 'ar';

    if (token.isEmpty) {
      print("⚠️ Warning: Token is empty in SharedPreferences");
    }

    return {'token': token, 'lang': lang};
  }

  // 1. جلب قائمة المحادثات
  Future<ConversationList?> getConversations({int page = 1}) async {
    try {
      final auth = await _getAuthData();
      final url = "$kBaseUrl${AppEndpoints.conversations}?page=$page";

      final data = await api.get(
        url: url,
        token: auth['token'], // كلاس Api سيتولى وضع Authorization: Bearer ...
        typeLanguage: auth['lang'],
      );

      return ConversationList.fromJson(data);
    } catch (e) {
      print("❌ ChatApi.getConversations error: $e");
      return null;
    }
  }

  // 2. جلب رسائل محادثة معينة
  Future<List<Message>> getMessages(int conversationId) async {
    try {
      final auth = await _getAuthData();
      final url =
          "${kBaseUrl}${AppEndpoints.conversations}/$conversationId/messages";

      final data = await api.get(
        url: url,
        token: auth['token'],
        typeLanguage: auth['lang'],
      );

      // تصحيح هيكلية البيانات: السيرفر يرسل القائمة داخل data['data']['data']
      if (data != null &&
          data['data'] != null &&
          data['data']['data'] != null) {
        List messagesJson = data['data']['data'] as List;
        return messagesJson.map((e) => Message.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print("❌ ChatApi.getMessages error: $e");
      return [];
    }
  }

  // 3. إرسال رسالة جديدة
  Future<bool> sendMessage({
    required int conversationId,
    required String message,
  }) async {
    try {
      final auth = await _getAuthData();
      final url =
          "${kBaseUrl}${AppEndpoints.conversations}/$conversationId/messages";

      final body = {'message': message};

      final data = await api.post(
        url: url,
        body: body,
        token: auth['token'],
        typeLanguage: auth['lang'],
      );

      // نتحقق من نجاح العملية حسب هيكلية كلاس Api الخاص بك
      return data != null && data['success'] == true;
    } catch (e) {
      print("❌ ChatApi.sendMessage error: $e");
      return false;
    }
  }

  // 4. إنشاء محادثة جديدة
  Future<Conversation?> createConversation({
    required int landlordId,
    required int tenantId,
  }) async {
    try {
      final auth = await _getAuthData();
      final url = "$kBaseUrl${AppEndpoints.conversations}";

      final body = {
        'landlord_id': landlordId.toString(),
        'tenant_id': tenantId.toString(),
      };

      final data = await api.post(
        url: url,
        body: body,
        token: auth['token'],
        typeLanguage: auth['lang'],
      );

      print('🟢 createConversation response: $data');

      if (data['success'] == true && data['data'] != null) {
        return Conversation.fromJson(data['data']);
      }
    } catch (e) {
      print("❌ ChatApi.createConversation error: $e");
    }
    return null;
  }
}
