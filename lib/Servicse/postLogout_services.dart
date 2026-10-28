import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostlogoutServices {
  Future<Map<String, dynamic>> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    // إرسال طلب تسجيل خروج
    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/logout',
      typeLanguage: cl.currentLanguage.value,
      token: token,
    );
    // await prefs.clear(); // مسح كل البيانات

    return data;
  }
}
                          
