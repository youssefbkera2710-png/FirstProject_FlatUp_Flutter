import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';

class PostloginServicse {
 Future<Map<String, dynamic>>  loginUser({
    required String email,
    required String password,
  }) async {
   final cl = Get.find<HomeController>();

   Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      typeLanguage: cl.currentLanguage.value,
      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
