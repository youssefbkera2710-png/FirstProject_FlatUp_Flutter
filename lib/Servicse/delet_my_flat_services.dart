import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteMyFlatServices {
  Future<bool> deleteMyApartment(int? idApartment) async {
    if (idApartment == null) {

      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final cl = Get.find<HomeController>();

    if (token == null || token.isEmpty) {

      return false;
    }

    String url = "$kBaseUrl/apartments/$idApartment";

    try {
      final response = await Api().delete(url: url, token: token,typeLanguage: cl.currentLanguage.value);

      return true;
    } catch (e) {
      print("📌 Stack Trace: ${e.toString()}");
      return false;
    }
  }
}
