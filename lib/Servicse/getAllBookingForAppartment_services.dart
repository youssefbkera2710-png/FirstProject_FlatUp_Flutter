import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/nav2/router_outlet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetallbookingforappartmentServices {
  Future<Map<String, dynamic>> getBooking({required int apartmentId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();


    Map<String, dynamic> respone = await Api().get(
      url: '$kBaseUrl/landlord/bookings/apartment/$apartmentId',
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
    return respone;
  }
}
