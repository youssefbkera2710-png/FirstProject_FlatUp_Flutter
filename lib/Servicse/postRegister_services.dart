import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';

class PostregisterServices {
  Future<Map<String, dynamic>> addUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String nationalid,
    required String role,
  }) async {
    HomeController cl = Get.find<HomeController>();
    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/auth/register',
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'national_id': nationalid,
        'role': role,
      },
      typeLanguage: cl.currentLanguage.value,
    );
    return data;
  }
}
