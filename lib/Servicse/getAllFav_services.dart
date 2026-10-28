import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetFavoriteApartmentsService {
  Future<List<ApartmentModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final cl = Get.find<HomeController>();

    final data = await Api().get(
      url: '$kBaseUrl/favorites',
      token: token,
      typeLanguage: cl.currentLanguage.value,
    );
final List favorites = data['data']['favorites'];

    return favorites
        .map((item) => ApartmentModel.fromJson(item['apartment']))
        .toList();
  } 
}
