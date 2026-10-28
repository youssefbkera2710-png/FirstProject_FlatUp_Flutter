import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationService {
  final String baseUrl;
  final String token;

  NotificationService({required this.baseUrl, required this.token});

  Future<NotificationList?> getNotifications({int page = 1, int? propertyId}) async {
    try {
      final Map<String, String> queryParams = {'page': '$page'};
      
      // إذا كان تطبيق شقق وأرسلت property_id
      if (propertyId != null) {
        queryParams['property_id'] = '$propertyId';
      }

      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
      
      print('🌐 API Request: $uri');
      print('🔑 Token: ${token.substring(0, 20)}...'); // طباعة أول 20 حرف فقط للأمان

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic jsonData = jsonDecode(response.body);
        
        // 🔍 طباعة هيكل البيانات للتحقق
        print('🔍 JSON Structure Type: ${jsonData.runtimeType}');
        if (jsonData is Map) {
          
          print('🔍 JSON Keys: ${jsonData.keys}');
          print('🔍 Has "data" key: ${jsonData.containsKey('data')}');
          print('🔍 Has "notifications" key: ${jsonData.containsKey('notifications')}');
          
          if (jsonData.containsKey('data')) {
            print('🔍 "data" type: ${jsonData['data'].runtimeType}');
            print('🔍 "data" value: ${jsonData['data']}');
          }
          
        }
        
        return NotificationList.fromJson(jsonData);
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in getNotifications: $e');
      print('❌ Stack trace: ${e.toString()}');
      return null;
    }
  }

  Future<bool> readNotification(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/$id/read');
      
      print('📤 Reading notification $id');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Read Notification Response: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error reading notification: $e');
      return false;
    }
  }

  Future<bool> readAllNotification({int? propertyId}) async {
    try {
      final uri = Uri.parse('$baseUrl/notifications/read-all');
      
      final Map<String, dynamic> body = {};
      
      // أضف property_id إذا كان مطلوب
      if (propertyId != null) {
        body['property_id'] = propertyId;
      }

      print('📤 Reading all notifications');
      print('📤 Body: $body');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body.isNotEmpty ? jsonEncode(body) : null,
      );

      print('📡 Read All Response: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error reading all notifications: $e');
      return false;
    }
  }

  Future<int> getUnreadCount({int? propertyId}) async {
    try {
      final Map<String, String> queryParams = {};
      
      // أضف property_id إذا كان مطلوب
      if (propertyId != null) {
        queryParams['property_id'] = '$propertyId';
      }

      final uri = Uri.parse('$baseUrl/notifications/unread-count').replace(queryParameters: queryParams);
      
      print('🔢 Getting unread count');
      print('🔢 URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Unread Count Response: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        
        // 🔍 تحقق من هيكل الاستجابة
        print('🔍 Unread count structure: $result');
        
        // حاول مع عدة أشكال للاستجابة
        if (result is Map) {
          if (result.containsKey('data') && result['data'] is Map) {
            return result['data']['count'] as int? ?? 0;
          } else if (result.containsKey('count')) {
            return result['count'] as int? ?? 0;
          } else if (result.containsKey('unread_count')) {
            return result['unread_count'] as int? ?? 0;
          }
        }
        
        return 0;
      }
      
      return 0;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }
}