

import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetMyApartments {
  Future<List<ApartmentModel>> getMyApartmentsByPage(
      int page, {
        int perPage = 10,
        String? q, // معامل البحث فقط
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final cl = Get.find<HomeController>();

    try {
      // رابط مع Pagination
      String url =
          "https://flatup.next99.net/api/my-apartments?page=$page&per_page=$perPage";

      // إضافة معامل البحث إذا موجود
      if (q != null && q.isNotEmpty) {
        url += "&q=${Uri.encodeComponent(q)}";
      }

      print("🌐 رابط الطلب: $url");

      dynamic response = await Api().get(
        url: url,
        token: token,
        typeLanguage: cl.currentLanguage.value
      );

      if (response is Map && response.containsKey('data')) {
        List<dynamic> dataList = response['data'];

        List<ApartmentModel> apartments = [];
        for (var item in dataList) {
          try {
            apartments.add(ApartmentModel.fromJson(item));
          } catch (e) {
            print("❌ خطأ في تحليل العنصر: $e");
          }
        }

        return apartments;
      } else {
        return [];
      }
    } catch (e) {
      print("❌ خطأ في getMyApartmentsByPage: $e");
      throw Exception("فشل في تحميل البيانات: $e");
    }
  }
}