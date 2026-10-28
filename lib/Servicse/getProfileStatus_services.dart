import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetprofilestatusServices {
  Future<Map<String, dynamic>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();
    Map<String, dynamic> respone = await Api().get(
      url: '$kBaseUrl/profile/status',
      token: token,
      typeLanguage: currentLanguage.currentLanguage.value,
    );
    return respone;
  }
}
