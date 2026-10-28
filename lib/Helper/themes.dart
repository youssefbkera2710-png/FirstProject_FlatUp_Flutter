import 'package:flat_up/constants/elementConstant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// colors.primary اللون الاساسي للثيم dark or light
// colors.secondary اللون الاساسي للثيم dark or light
// colors.onPrimary بالدارك اسود وبالايت ابيض
// isDark ? Colors.black : Colors.white,    لاختيار الالوان لبدك ياها بالوضعين

// ===============================
// THEME CONTROLLER مع حفظ الثيم
// ===============================

class Themes extends ChangeNotifier {
  bool isDark = false;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDark = !isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
    if (Get.context != null) {
      Get.changeTheme(isDark ? buildDarkTheme() : buildLightTheme());
    }
  }
}

// ===============================
// LIGHT & DARK THEMES (CUSTOM COLORS)
// ===============================
ThemeData buildLightTheme() {
  const primary = kPrimaryColorLight1;
  const secondary = kSecondaryColorLight;

  return ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: kPrimaryColorLight2,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
    ),
  );
}

ThemeData buildDarkTheme() {
  const primary = kPrimaryColorDark1;
  const secondary = kSecondaryColorDark;

  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: kPrimaryColorDark2,
    colorScheme: const ColorScheme.dark(primary: primary, secondary: secondary),
  );
}
