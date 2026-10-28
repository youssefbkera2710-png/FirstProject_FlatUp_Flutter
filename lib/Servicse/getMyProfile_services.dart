import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetmyprofileServices {
  Future<UserModels> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();
    final data = await Api().get(
      url: '$kBaseUrl/me',
      token: token,
      typeLanguage: currentLanguage.currentLanguage.value,
    );

    return UserModels.fromJson(data['user']);
  }
}
