import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PostresendotpSevices {
 Future<Map<String, dynamic>>  resendOtp({
    required String email,
  }) async {
    final currentLanguage = Get.find<HomeController>();
    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/resend-otp',
      body: {
        'email': email,
      },
      typeLanguage: currentLanguage.currentLanguage.value,
      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
