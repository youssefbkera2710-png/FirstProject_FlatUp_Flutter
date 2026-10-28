import 'package:flutter/material.dart';
import 'package:flat_up/Helper/localization_service.dart';

BottomNavigationBar buildBottomNavigationBar(
  BuildContext context,
  LocalizationService localizations,
  int currentIndexs,
  Function(int) onTap,
  String userStatus,
) {
  final colors = Theme.of(context).colorScheme;

  // بناء قائمة العناصر بناءً على حالة المستخدم
  List<BottomNavigationBarItem> items = [];

  // العنصر الأول: الدردشة
  items.add(
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildIcon(
          icon: Icons.chat_outlined,
          isActive: currentIndexs == 0,
          size: 22,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildActiveIcon(icon: Icons.chat, size: 26),
      ),
      label: localizations.translate('chat'),
    ),
  );

  // العنصر الثاني: الإشعارات
  items.add(
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildIcon(
          icon: Icons.home_repair_service_outlined,
          isActive: currentIndexs == 1,
          size: 22,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildActiveIcon(icon: Icons.home_repair_service, size: 26),
      ),
      label: userStatus == 'landlord'
          ? localizations.translate('myapartment')
          : localizations.translate('mybooking'),
    ),
  );

  // إذا كان المستخدم landlord، نضيف عنصرًا فارغًا في المنتصف
  if (userStatus == 'landlord') {
    items.add(
      const BottomNavigationBarItem(
        icon: SizedBox(width: 40, height: 40),
        label: '',
      ),
    );
  }

  // العنصر الثالث: المفضلة
  items.add(
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildIcon(
          icon: Icons.favorite_border,
          // حساب الفهرس الصحيح بناءً على حالة المستخدم
          isActive: userStatus == 'landlord'
              ? currentIndexs == 3
              : currentIndexs == 2,
          size: 22,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildActiveIcon(icon: Icons.favorite, size: 26),
      ),
      label: localizations.translate('favorites'),
    ),
  );

  // العنصر الرابع: الرئيسية
  items.add(
    BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildIcon(
          icon: Icons.home_outlined,
          // حساب الفهرس الصحيح بناءً على حالة المستخدم
          isActive: userStatus == 'landlord'
              ? currentIndexs == 4
              : currentIndexs == 3,
          size: 22,
        ),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(6),
        child: _buildActiveIcon(icon: Icons.home, size: 26),
      ),
      label: localizations.translate('home'),
    ),
  );

  // ضبط currentIndex ليكون ضمن النطاق الصحيح
  int adjustedCurrentIndex = currentIndexs;
  if (adjustedCurrentIndex >= items.length) {
    adjustedCurrentIndex = items.length - 1;
  }

  return BottomNavigationBar(
    currentIndex: adjustedCurrentIndex,
    onTap: onTap,
    type: BottomNavigationBarType.fixed,
    backgroundColor: colors.primary,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
    selectedLabelStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      height: 1.2,
    ),
    elevation: 8,
    items: items,
  );
}

// 🔽 دالة لبناء الأيقونة العادية
Widget _buildIcon({
  required IconData icon,
  required bool isActive,
  required double size,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: size, color: isActive ? Colors.white : Colors.white70),
      // 🔽 إضافة نقطة صغيرة تحت الأيقونة النشطة
      if (isActive)
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        )
      else
        const SizedBox(height: 6), // مسافة للحفاظ على التنسيق
    ],
  );
}

// 🔽 دالة لبناء الأيقونة النشطة بتصميم مميز
Widget _buildActiveIcon({required IconData icon, required double size}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(4), // 🔽 زيادة الحشوة
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // 🔽 خلفية شفافة
          borderRadius: BorderRadius.circular(12), // 🔽 زوايا مدورة
        ),
        child: Icon(icon, size: size, color: Colors.white),
      ),
      // 🔽 نقطة مؤشر أكبر للأيقونة النشطة
      Container(
        margin: const EdgeInsets.only(top: 4),
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}
