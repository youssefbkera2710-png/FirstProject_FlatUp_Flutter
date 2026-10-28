import 'package:firebase_core/firebase_core.dart';
import 'package:flat_up/Controller/chat_controller.dart';
import 'package:flat_up/Helper/chat_injection.dart';
import 'package:flat_up/Pages/chat_page.dart';
import 'package:flat_up/Pages/conversations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/Helper/appRouterClass.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Init/notification_init.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Pages/addEditApartmentPage.dart';
import 'package:flat_up/Pages/completeProfile_Page.dart';
import 'package:flat_up/Pages/favourite_page.dart';
import 'package:flat_up/Pages/forgetPassword_page.dart';
import 'package:flat_up/Pages/getStarted_page.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Pages/informationVendor_page.dart';
import 'package:flat_up/Pages/informationsProfile_page.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Pages/myFlat_page.dart';
import 'package:flat_up/Pages/my_booking_page.dart';
import 'package:flat_up/Pages/notifications_page.dart';
import 'package:flat_up/Pages/privacyPolicy_page.dart';
import 'package:flat_up/Pages/register_page.dart';
import 'package:flat_up/Pages/resetPasswordPage.dart';
import 'package:flat_up/Pages/singleProduct1_page.dart';
import 'package:flat_up/Pages/verify_page.dart';
import 'package:flat_up/Pages/waiting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 🔔 1. تهيئة الإشعارات
  await NotificationInitializer.init();

  // 💬 2. تهيئة الشات (بعد SharedPreferences)
  await ChatInjection.init();

  // 🎨 3. تهيئة الثيم
  final themeController = Themes();
  await themeController.loadTheme();

  // 🧭 4. تحديد أول Route
  final initialRoute = await AppRouterClass.getStartRoute();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => themeController)],
      child: FlatUp(initialRoute: initialRoute),
    ),
  );
}

class FlatUp extends StatelessWidget {
  final String initialRoute;

  FlatUp({super.key, required this.initialRoute});

  // 🧠 Home Controller
  final HomeController homeController = Get.put(
    HomeController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<Themes>(
      builder: (context, theme, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.isDark ? buildDarkTheme() : buildLightTheme(),
          locale: Locale(homeController.currentLanguage.value),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            LocalizationService.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ============ ROUTES ============
          routes: {
            // 🆕 صفحات الشات
            ConversationsPage.routeName: (context) => ConversationsPage(),

            ChatPage.routeName: (context) {
              final routeArgs = ModalRoute.of(context)?.settings.arguments;

              if (routeArgs is Map<String, dynamic>) {
                final conversationId = routeArgs['conversationId'];

                if (conversationId == null) {
                  return ConversationsPage();
                }

                return ChatPage(
                  conversationId: conversationId,
                  otherUserName: routeArgs['otherUserName'], // ممكن تكون null
                  avatar: routeArgs['avatar'], // ممكن تكون null
                );
              }
              return ConversationsPage();
            },

            // الصفحات القديمة
            LoginPage.id: (context) => LoginPage(),
            RegisterPage.id: (context) => RegisterPage(),
            VerifyPage.id: (context) => VerifyPage(),
            CompleteprofilePage.id: (context) => CompleteprofilePage(),
            PrivacypolicyPage.id: (context) => PrivacypolicyPage(),
            NotificationsPage.id: (context) => NotificationsPage(),
            MyflatPage.id: (context) => MyflatPage(),
            InformationvendorPage.id: (context) => InformationvendorPage(),
            InformationsprofilePage.id: (context) => InformationsprofilePage(),
            HomevendorPage.id: (context) => HomevendorPage(),
            FavouritePage.id: (context) => FavouritePage(),
            SingleProductPage.id: (context) => SingleProductPage(),
            WaitingPage.id: (context) => WaitingPage(),
            ForgetpasswordPage.id: (context) => ForgetpasswordPage(),
            Resetpasswordpage.id: (context) => Resetpasswordpage(),
            MyBookingPage.id: (context) => MyBookingPage(),
            GetstartedPage.id: (context) => GetstartedPage(),
          },

          onGenerateRoute: (settings) {
            if (settings.name == AddEditApartmentPage.id) {
              final args = settings.arguments;

              if (args != null && args is Map<String, dynamic>) {
                return MaterialPageRoute(
                  builder: (context) =>
                      AddEditApartmentPage(apartment: args['apartment']),
                );
              }

              return MaterialPageRoute(
                builder: (context) => AddEditApartmentPage(),
              );
            }

            return null;
          },

          // 🆕 إعدادات
          defaultTransition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),

          initialRoute: initialRoute,
        );
      },
    );
  }
}
