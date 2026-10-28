import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:flat_up/Models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetMyBookingsService {
  Future<List<BookingModel>> getMyBookingsByPage(int page, {String? q}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final cl = Get.find<HomeController>();

    try {
      String url = '$kBaseUrl/bookings';

      if (q != null && q.isNotEmpty) {
        url += '&search=$q';
      }

      var response = await Api().get(url: url, token: token,typeLanguage: cl.currentLanguage.value);

      List<dynamic> bookingsData = response['data'];
      List<BookingModel> bookings = bookingsData
          .map((json) => BookingModel.fromJson(json))
          .toList();

      return bookings;
    } catch (e) {
      print('❌ خطأ في getMyBookingsByPage: $e');
      throw e;
    }
  }
}
