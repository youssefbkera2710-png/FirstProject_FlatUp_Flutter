import 'dart:convert';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelBookingService {
  Future<bool> cancelBooking(int bookingId) async {
    try {
      String url = '$kBaseUrl/bookings/$bookingId/cancel';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? "";
      final cl = Get.find<HomeController>();

      var response = await Api().post(
        url: url,
        body: json.encode({}),
        token: token,
        typeLanguage: cl.currentLanguage.value
      );

      var data = response;
      return true;
    } catch (e) {
      print('❌ خطأ في cancelBooking: $e');
      return false;
    }
  }
}
