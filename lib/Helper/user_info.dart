// config/user_info.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static String token = '';
  static int id = 0;
  static String firstName = '';
  static String lastName = '';
  static String name = '';
  static String email = '';

  static Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ?? '';
      id = prefs.getInt('id') ?? int.tryParse(prefs.getString('id') ?? '') ?? 0;
      firstName = prefs.getString('first_name') ?? '';
      lastName = prefs.getString('last_name') ?? '';
      name = "$firstName $lastName";
      email = prefs.getString('email') ?? '';

      print('🔑 UserInfo loaded:');
      print('   - ID: $id');
      print('   - Name: $name');
      print('   - Token exists: ${token.isNotEmpty}');
    } catch (e) {
      print('❌ Error loading UserInfo: $e');
    }
  }

  static Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token.isNotEmpty) await prefs.setString('token', token);
      if (id > 0) await prefs.setInt('id', id);
      if (name.isNotEmpty) await prefs.setString('name', name);
      if (email.isNotEmpty) await prefs.setString('email', email);
      print('💾 UserInfo saved');
    } catch (e) {
      print('❌ Error saving UserInfo: $e');
    }
  }

  static void updateToken(String newToken) {
    token = newToken;
    saveToStorage();
  }

  static void clear() {
    token = '';
    id = 0;
    name = '';
    email = '';
  }
}
