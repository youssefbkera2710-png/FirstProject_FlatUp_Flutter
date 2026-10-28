import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class GetallprovinesServices {
  HomeController h = Get.find<HomeController>();
  Future<List<ProvinesModels>> getProvines() async {
    final currentLaunage = Get.find<HomeController>();
    final response = await Api().get(
      url: '$kBaseUrl/provinces',
      typeLanguage: currentLaunage.currentLanguage.value,
    );
    // response["data"] يحتوي على قائمة المحافظات
    List<dynamic> data = response['data'];
    return data.map((e) => ProvinesModels.fromJson(e)).toList();
  }
}
