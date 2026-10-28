import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeletereviewServices {
  final Api _api = Api();

  Future<Map<String, dynamic>> deleteReview({required int reviewId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    return await _api.delete(
      url: '$kBaseUrl/reviews/$reviewId',
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
  }
}
