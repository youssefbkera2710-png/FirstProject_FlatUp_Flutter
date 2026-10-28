import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Getcheckfavapartment {
  Future<Map<String, dynamic>> getCheckFav({required int apartmentId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    Map<String, dynamic> respone = await Api().get(
      url: '$kBaseUrl/favorites/check/$apartmentId',
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
    return respone;
  }
}
