import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';

class PostverifiyotpServices {
 Future<Map<String, dynamic>>  verifyOtp({
    required String email,
    required String otp,
  }) async {
   final cl = Get.find<HomeController>();

   Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/verify-otp',
      body: {
        'email': email,
        'otp': otp,
      },
      typeLanguage: cl.currentLanguage.value,
      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
