import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Pages/favourite_page.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Pages/informationsProfile_page.dart';
import 'package:flat_up/Pages/my_booking_page.dart';
import 'package:flat_up/Pages/notifications_page.dart';
import 'package:flat_up/constants/flat_notification_types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flat_up/models/notification_model.dart';

class FlatNotificationRouter {
  static void navigate(NotificationItem notification) {
    final payload = notification.payload;

    switch (notification.type) {
      case FlatNotificationTypes.favorite_added:
        final homeController = Get.find<HomeController>();

        Get.toNamed(HomevendorPage.id);

        Future.delayed(const Duration(milliseconds: 300), () {
          homeController.changePage(
            homeController.userStatus.value == 'tenant' ? 2 : 3,
          );
        });

        break;

      case FlatNotificationTypes.booking_creation:
      case FlatNotificationTypes.booking_update:
      case FlatNotificationTypes.booking_cancellation:
        final homeController = Get.find<HomeController>();

        // نفتح الصفحة الرئيسية الأساسية
        Get.offAllNamed(HomevendorPage.id);

        Future.delayed(const Duration(milliseconds: 300), () {
          if (homeController.userStatus.value == 'tenant') {
            // 👉 حجوزاتي
            homeController.changePage(1);
          } else {
            // 👉 هوم للمالك
            homeController.changePage(4);
          }
        });
        break;

      // case FlatNotificationTypes.estate:
      //   Get.toNamed(
      //     '/maintenance-details',
      //     arguments: {
      //       'maintenance_id':
      //           payload['maintenance_id'] ?? notification.relatedEntityId,
      //       'apartment_id': payload['apartment_id'],
      //       'notification_data': payload,
      //     },
      //   );
      //   break;

      case FlatNotificationTypes.user_approval:
        Get.offNamed(
          InformationsprofilePage.id,
          arguments: {'fromNotification': true},
        );
        break;

      case FlatNotificationTypes.security:
        // عرض تفاصيل تسجيل الدخول
        Get.defaultDialog(
          title: 'تنبيه أمان',
          content: Column(
            children: [
              Text('وقت الدخول: ${payload['login_time']}'),
              Text('IP: ${payload['ip']}'),
              Text('الجهاز: ${payload['user_agent']}'),
            ],
          ),
        );
        break;
      default:
        Get.toNamed(NotificationsPage.id);
    }
  }
}
