import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostAllReviewApartmentServices {
  final Api _api = Api();

  Future<Map<String, dynamic>> getReviews({
    required int apartmentId,
    int page = 1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    Map<String, String> body = {
      'apartment_id': apartmentId.toString(),
      'page': page.toString(),
    };

    return await _api.post(
      url: '$kBaseUrl/all-reviews',
      body: body,
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
  }
}
