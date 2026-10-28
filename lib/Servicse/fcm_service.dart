import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  /// جلب FCM Token
  static Future<String?> getFcmToken() async {
    final tokenFcm = await _messaging.getToken();
    print('🔥 FCM TOKEN: $tokenFcm');
    return tokenFcm;
  }

  /// الاستماع لتغير التوكن
  static void listenTokenRefresh(
    Future<void> Function(String tokenFcm) onRefresh,
  ) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newtokenFcm) {
      print('♻️ FCM Token Refreshed: $newtokenFcm');
      onRefresh(newtokenFcm);
    });
  }
}
