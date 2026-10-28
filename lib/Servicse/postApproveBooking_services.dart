import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostapprovebookingServices {
  final Api _api = Api();

  Future<Map<String, dynamic>> approveBooking({
    required int bookingId
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    return await _api.post(
      url: '$kBaseUrl/landlord/bookings/$bookingId/approve',
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
  }
}
