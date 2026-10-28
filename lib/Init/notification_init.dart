import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flat_up/Controller/notifications_controller.dart';
import 'package:flat_up/Pages/notifications_page.dart';
import 'package:flat_up/Servicse/local_notification_service.dart';
import 'package:get/get.dart';

class NotificationInitializer {
  static Future<void> init() async {
    print('🚀 Starting notification initialization...');

    try {
      // 1. تهيئة الإشعارات المحلية
      await LocalNotificationService.initialize();

      // 2. تهيئة Firebase (إذا كان عندك Firebase)
      await _initFirebaseIfAvailable();

      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  static Future<void> _initFirebaseIfAvailable() async {
    try {
      // طلب الأذونات
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // الحصول على token
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('🔥 FCM Token: $token');
        await _sendTokenToServer(token);
      }

      // إعداد المستمعين
      _setupFirebaseListeners();
    } catch (e) {
      print('⚠️ Firebase not configured: $e');
    }
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      // هنا استخدم الـ API service حقك
      // مثال:
      // final apiService = Get.find<ApiService>();
      // await apiService.post('fcm-token', {'token': token});
      print('📤 FCM Token: $token');
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  static void _setupFirebaseListeners() {
    // عند استلام إشعار والتطبيق مفتوح
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground notification received');

      // 🔔 إشعار محلي
      LocalNotificationService.showSimpleNotification(
        title: message.notification?.title ?? 'إشعار',
        body: message.notification?.body ?? '',
        payload: message.data,
      );

      // 🧠 تحديث الإشعارات داخل التطبيق
      if (Get.isRegistered<NotificationsController>()) {
        final controller = Get.find<NotificationsController>();

        controller.fetchUnreadCount(); // تحديث العداد
        controller.fetchNotifications(reset: true); // 👈 تحديث اللائحة فوراً
      } else {
        print('⚠️ NotificationsController not registered yet');
      }
    });

    // عند النقر على إشعار والتطبيق بالخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notification clicked (background)');
      _handleNotificationTap(message.data);
    });

    // عند فتح التطبيق من إشعار (terminated)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('📱 App opened from notification (terminated)');
        _handleNotificationTap(message.data);
      }
    });
  }

  static void _handleNotificationTap(Map<String, dynamic> data) {
    // افتح صفحة الإشعارات مباشرة أو استخدم الراوتر
    Get.toNamed(NotificationsPage.id);

    // أو يمكنك إنشاء notification item ومعالجته
    // final notification = NotificationItem.fromJson(data);
    // FlatNotificationRouter.navigate(notification);
  }
}
