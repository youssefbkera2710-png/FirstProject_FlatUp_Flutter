import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostcheckavilableServices {
  Future<Map<String, dynamic>> checkAvilable({
    required int apartmentId,
    required String startDate,
    required String endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    Map<String, dynamic> data = await Api().post(
      url: '$kBaseUrl/check-availability',
      body: {
        'apartment_id': apartmentId.toString(),
        'start_date': startDate.toString(),
        'end_date': endDate.toString(),
      },
      typeLanguage: cl.currentLanguage.value,
      token: token,

      // هون شرط اللغة بدي ساويه تابع
    );
    return data;
  }
}
