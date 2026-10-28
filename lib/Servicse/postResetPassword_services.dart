import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';

class PostresetpasswordServices {
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final cl = Get.find<HomeController>();

    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/reset-password',
      body: {'email': email, 'otp': code, 'new_password': newPassword},
      typeLanguage: cl.currentLanguage.value,
      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
