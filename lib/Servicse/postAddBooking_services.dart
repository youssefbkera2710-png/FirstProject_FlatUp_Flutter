import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostaddbookingServices {
  final Api _api = Api();

  Future<Map<String, dynamic>> createBooking({
    required int apartmentId,
    required String startDate,
    required String endDate,
    required int numberOfGuests,
    required String specialRequests,
    required String paymentIntentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();

    Map<String, String> body = {
      'apartment_id': apartmentId.toString(),
      'start_date': startDate.toString(),
      'end_date': endDate.toString(),
      'number_of_guests': numberOfGuests.toString(),
      'special_requests': specialRequests.toString(),
      'payment_intent_id': paymentIntentId.toString(),
    };
    return await _api.post(
      url: '$kBaseUrl/bookings',
      body: body,
      token: token,
      typeLanguage: currentLanguage.currentLanguage.value,
    );
  }
}
