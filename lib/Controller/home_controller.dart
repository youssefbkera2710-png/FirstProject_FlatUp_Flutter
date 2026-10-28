import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  // حالة الصفحة الحالية - نبدأ بالصفحة الرئيسية
 var currentIndex = 0.obs;
 // نبدأ بالصفحة الرئيسية (home)

  // حالة اللغة
  var currentLanguage = 'en'.obs;

  // حالة الوضع الليلي
  var isDarkMode = false.obs;

  // حالة المستخدم
  var userStatus = 'tenant'.obs; // tenant أو landlord

  @override
  void onInit() {
    super.onInit();
    loadLanguage(); // تحميل اللغة عند تشغيل التطبيق
  }

  // تحميل اللغة من SharedPreferences
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLanguage.value = prefs.getString('appLanguage') ?? 'en';
    Get.updateLocale(Locale(currentLanguage.value));
  }

  // تغيير الصفحة
  void changePage(int index) {
    currentIndex.value = index;
    update(); // تحديث جميع الويدجت التي تستخدم هذا الكونترولر
  }

  // تغيير اللغة + حفظها
  Future<void> changeLanguage() async {
    currentLanguage.value = currentLanguage.value == 'en' ? 'ar' : 'en';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', currentLanguage.value);

    Get.updateLocale(Locale(currentLanguage.value));
    update();
  }

  // تغيير الوضع الليلي
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
    update(); // تحديث جميع الويدجت التي تستخدم هذا الكونترولر
  }

  // تحديث حالة المستخدم
  void updateUserStatus(String status) {
    userStatus.value = status;
    update(); // تحديث جميع الويدجت التي تستخدم هذا الكونترولر
  }
}
