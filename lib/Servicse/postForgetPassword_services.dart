import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';

class PostforgetpasswordServices {
 Future<Map<String, dynamic>>  forgetPassword({
    required String email,
  }) async {
   final cl = Get.find<HomeController>();

   Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/forgot-password',
      body: {
        'email': email,
      },
      typeLanguage: cl.currentLanguage.value,
      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
