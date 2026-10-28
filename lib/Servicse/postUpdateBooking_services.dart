import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostupdatebookingServices {
  final Api _api = Api();

  Future<Map<String, dynamic>> updateBooking({
    required int bookingId,
    required String startDate,
    required String endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();

    Map<String, String> body = {
      'start_date': startDate.toString(),
      'end_date': endDate.toString(),
    };
    return await _api.post(
      url: '$kBaseUrl/bookings/$bookingId',
      body: body,
      token: token,
      typeLanguage: currentLanguage.currentLanguage.value,
    );
  }
}
