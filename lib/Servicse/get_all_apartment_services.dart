import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/apartment_model.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetAllApartment {
  Future<List<ApartmentModel>> getApartmentsByPage(
    int page, {
    int perPage = 10,
    String? q,
    double? minPrice,
    double? maxPrice,
    int? provinceId,
    String? propertyType,
    int? roomsCount,
    String? rentType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final currentLanguage = Get.find<HomeController>();

    try {
      String url = "$kBaseUrl/apartments?page=$page&per_page=$perPage";

     
      if (q != null && q.isNotEmpty) {
        url += "&q=${Uri.encodeComponent(q)}";
      }

     
      if (minPrice != null && minPrice > 0) {
        url += "&min_price=${minPrice.toString()}";
      }

      if (maxPrice != null && maxPrice < 1000000) {
        url += "&max_price=${maxPrice.toString()}";
      }

     
      if (provinceId != null) {
        url += "&province_id=${provinceId.toString()}";
      }

     
      if (propertyType != null &&
          propertyType.isNotEmpty &&
          propertyType != 'all') {
        url += "&property_type=${Uri.encodeComponent(propertyType)}";
      } 

      // إضافة معامل عدد الغرف (للجميع)
      if (roomsCount != null && roomsCount > 0) {
        url += "&rooms_count=${roomsCount.toString()}";
      }

      // إضافة معامل نوع الإيجار (للمستأجر فقط)
      if (rentType != null && rentType.isNotEmpty && rentType != 'all') {
        url += "&rent_type=${Uri.encodeComponent(rentType)}";
      }


      dynamic response = await Api().get(
        url: url,
        token: token,
        typeLanguage: currentLanguage.currentLanguage.value,
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
      print("❌ خطأ في getApartmentsByPage: $e");
      throw Exception("فشل في تحميل البيانات: $e");
    }
  }
}
