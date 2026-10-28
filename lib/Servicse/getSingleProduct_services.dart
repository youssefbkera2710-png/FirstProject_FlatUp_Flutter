// single_product_service.dart
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetsingleproductServices {
  final Api _api = Api();

  Future<ApartmentModel> getSingleProduct({
    required int apartmentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();
      final data = await _api.get(
        url: '$kBaseUrl/apartments/$apartmentId',
        token: token, 
        typeLanguage: currentLanguage.currentLanguage.value
      );
        return ApartmentModel.fromJson(data['data']);
  }
}
