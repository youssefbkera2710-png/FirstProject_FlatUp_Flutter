import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosttogglefavServices {
  Future<Map<String, dynamic>> addFav({required String idAppartment}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/favorites/toggle',
      body: {'apartment_id': idAppartment},
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
    return data;
  }
}
