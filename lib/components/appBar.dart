import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Pages/myFlat_page.dart';
import 'package:flat_up/Pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';

AppBar buildAppBar(
  BuildContext context,
  LocalizationService localizations, {
  required Function(String) onSearch,
  required Function() onClearSearch,
  required TextEditingController searchController,
  required ColorScheme colors,
}) {

  return AppBar(
    iconTheme: IconThemeData(color: kPrimaryColorLight2),
    backgroundColor: colors.primary,
    elevation: 2,
    title: Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, NotificationsPage.id);
          },
          icon: const Icon(Icons.notifications, color: Colors.white),
          tooltip: localizations.translate('notifications'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 45,
            child: TextField(
              controller: searchController, // التحكم في نص الحقل
              onSubmitted: onSearch, // البحث مع الحفاظ على الفلترة
              decoration: InputDecoration(
                hintText: localizations.translate('searchHint'),
                hintStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white24,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          searchController.clear();
                          onClearSearch(); // مسح البحث مع الحفاظ على الفلترة
                        },
                      )
                    : null,
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
