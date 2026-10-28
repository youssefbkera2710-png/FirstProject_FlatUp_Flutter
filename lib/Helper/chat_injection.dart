import 'package:flat_up/Controller/chat_controller.dart';
import 'package:flat_up/Servicse/chat_api.dart';
import 'package:flat_up/Servicse/realtime_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatInjection {
  static Future<void> init() async {
        final prefs = await SharedPreferences.getInstance();
    print('✅ Chat injection initialized');

    Get.lazyPut(() => ChatApi(), fenix: true);
    Get.lazyPut(() => RealtimeService(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
  }
}