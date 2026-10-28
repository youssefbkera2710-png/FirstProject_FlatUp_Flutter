import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:flat_up/Pages/informationsProfile_page.dart';
import 'package:flat_up/Servicse/getMyProfile_services.dart';
import 'package:flat_up/components/user_header.dart';
import 'package:flat_up/widget/button_theme.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DrawerItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color color;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.color = Colors.white,
  });

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white54,
      elevation: 0,
      child: ListTile(
        leading: Icon(widget.icon, color: widget.color, size: 24),
        title: Text(
          widget.title,
          style: TextStyle(color: widget.color, fontSize: 16),
        ),
        trailing: widget.trailing,
        onTap: widget.onTap,
      ),
    );
  }
}

Drawer buildDrawer(
  BuildContext context,
  LocalizationService localizations,
  Themes themeController,
  bool isDark,
  VoidCallback onLogout,
  ColorScheme colors,
) {
  final HomeController controller = Get.find<HomeController>();

  return Drawer(
    backgroundColor: colors.primary,
    width: 280,
    child: SafeArea(
      child: Column(
        children: [
          UserHeader(localizations: localizations),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DrawerItem(
                  icon: Icons.account_circle,
                  title: localizations.translate('myAccount'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InformationsprofilePage(),
                      ),
                    );
                  },
                ),
                DrawerItem(
                  icon: Icons.language,
                  title: localizations.translate('language'),
                  trailing: Obx(
                    () => Text(
                      controller.currentLanguage.value.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    controller.changeLanguage();
                  },
                ),
                DrawerItem(
                  icon: isDark ? Icons.nightlight_round : Icons.wb_sunny,
                  title: localizations.translate('darkMode'),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeController.toggleTheme();
                    },
                  ),
                  onTap: () {
                    themeController.toggleTheme();
                  },
                ),
                const Divider(color: Colors.white54, height: 32),
                DrawerItem(
                  icon: Icons.share,
                  title: localizations.translate('share'),
                  onTap: () {
                    Get.defaultDialog(
                      title: localizations.translate('ShareTitle'),
                      middleText: localizations.translate('confirmShare'),
                      textConfirm: localizations.translate('share'),
                      textCancel: localizations.translate('cancel'),
                      onConfirm: () async {
                        await Share.share(
                          'جرب تطبيقنا الجديد الآن!\n\nرابط التحميل: https://example.com/app',
                          subject: 'عنوان المشاركة',
                        );
                        Get.back();
                      },
                    );
                  },
                ),
                DrawerItem(
                  icon: Icons.lock,
                  title: localizations.translate('privacy'),
                ),
              ],
            ),
          ),
          // 🔽 زر تسجيل الخروج في الأسفل
          DrawerItem(
            icon: Icons.logout_outlined,
            title: localizations.translate('logOut'),
            onTap: onLogout,
            color: Colors.red,
          ),
        ],
      ),
    ),
  );
}
