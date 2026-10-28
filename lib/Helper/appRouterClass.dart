import 'package:flat_up/Pages/getStarted_page.dart';
import 'package:flat_up/Pages/verify_page.dart';
import 'package:flat_up/Pages/waiting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Pages/completeProfile_Page.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';

class AppRouterClass {
  static Future<String> getStartRoute() async {
    final prefs = await SharedPreferences.getInstance();

    final hasSeenGetStarted = prefs.getBool('has_seen_get_started') ?? false;

    // ✅ 1. Get Started (مرة وحدة فقط)
    if (!hasSeenGetStarted) {
      return GetstartedPage.id;
    }

    final token = prefs.getString('token');
    final email = prefs.getString('email');
    final isComplete = prefs.getBool('is_profile_complete');
    final step = prefs.getString('step');
    final status = prefs.getString('status');

    // ✅ 2. Login
    if (email == null || email.isEmpty) {
      return LoginPage.id;
    }

    // ✅ 3. Verify Email
    if (token == null || step == 'verify_email') {
      return VerifyPage.id;
    }

    // ✅ 4. Complete Profile
    if (isComplete == false || step == 'complete_profile') {
      return CompleteprofilePage.id;
    }

    // ✅ 5. Waiting Approval
    if ((isComplete == true && status == 'rejected') ||
        (isComplete == true && status == 'pending_approval') ||
        step == 'waiting_approval') {
      return WaitingPage.id;
    }

    // ✅ 6. Home
    if (status == 'approved' || step == 'done') {
      return HomevendorPage.id;
    }

    return LoginPage.id;
  }
}
