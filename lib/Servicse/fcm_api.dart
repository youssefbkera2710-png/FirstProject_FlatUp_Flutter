import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_endpoints.dart';
import '../constants/elementConstant.dart';

class FcmApi {
  Future<void> sendTokenToBackend(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // JWT / Sanctum token

    final url = Uri.parse('$kBaseUrl');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'fcm_token': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل إرسال FCM Token');
    }
  }
}
