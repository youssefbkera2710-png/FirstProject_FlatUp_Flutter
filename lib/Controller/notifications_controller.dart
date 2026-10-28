import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/models/notification_model.dart';
import 'package:flat_up/router/flat_notification_router.dart';
import 'package:flat_up/Servicse/notifications_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  late NotificationService _service;

  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;

  final RxInt unreadCount = 0.obs;
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  int _currentPage = 1;
  int? _propertyId;
  final RxBool isReadingAll = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    _service = NotificationService(baseUrl: kBaseUrl, token: token);
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;

    await Future.wait([fetchNotifications(reset: true), fetchUnreadCount()]);

    isLoading.value = false;
  }

  Future<void> fetchNotifications({bool reset = false}) async {
    if (reset) {
      _currentPage = 1;
      hasMore.value = true;
      notifications.clear();
    }

    if (!hasMore.value) return;

    if (_currentPage > 1) isLoadingMore.value = true;

    final result = await _service.getNotifications(
      page: _currentPage,
      propertyId: _propertyId,
    );

    if (result != null && result.success) {
      // ✅ استخدم result.notifications إذا كان الاسم مختلف
      final List<NotificationItem> items = result.notifications; // ✅ مباشرة

      if (items.isEmpty) {
        hasMore.value = false;
      } else {
        notifications.addAll(items); // ✅ الآن مؤكد List<NotificationItem>
        _currentPage++;
      }
    } else {
      hasMore.value = false;
    }

    isLoadingMore.value = false;
  }

  Future<void> onNotificationTap(NotificationItem notification) async {
    if (!notification.isRead) {
      await readNotification(notification.id);
    }

    await Future.delayed(const Duration(milliseconds: 150));

    // التعامل مع الإشعار حسب نوعه
    _handleNotificationNavigation(notification);
  }

  void _handleNotificationNavigation(NotificationItem notification) {
    // استخدم الراوتر الجديد
    FlatNotificationRouter.navigate(notification);
  }

  Future<void> fetchUnreadCount() async {
    unreadCount.value = await _service.getUnreadCount(propertyId: _propertyId);
  }

  Future<void> readNotification(int id) async {
    final success = await _service.readNotification(id);
    if (success) {
      // تحديث محلي
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        notifications.refresh();
      }

      // تحديث العداد
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    }
  }

  Future<void> readAll() async {
    if (isReadingAll.value) return;

    isReadingAll.value = true;

    final success = await _service.readAllNotification(propertyId: _propertyId);

    if (success) {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
      notifications.refresh();

      unreadCount.value = 0;

      Get.snackbar('تم', 'تم تحديد جميع الإشعارات كمقروءة');
    }

    isReadingAll.value = false;
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      fetchNotifications();
    }
  }
}
