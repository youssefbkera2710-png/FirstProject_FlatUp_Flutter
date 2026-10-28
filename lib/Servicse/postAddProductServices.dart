
import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:flat_up/Controller/home_controller.dart';

class PostAddProductServices {
  Future<Map<String, dynamic>> addProduct({
    required String title,
    required String description,
    required double area,
    required String rent_type,
    required String city,
    required double price,
    required int rooms_count,
    required int bathrooms_count,
    required ProvinesModels province,
    required String property_type,
    required int balconies_count,
    required bool has_roof,
    required String floor,
    required bool has_electricity_meter,
    required bool has_water_counter,
    required bool is_furnished,
    required bool has_solar_energy,
    required bool is_deluxe,
    required File mainImage, // ✅ صورة رئيسية مطلوبة
    required List<File> additionalImages, // ✅ صور إضافية
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();

    // 1. إعداد الحقول النصية
    Map<String, String> fields = {
      'title': title,
      'description': description,
      'area': area.toString(),
      'rent_type': rent_type,
      'city': city,
      'price': price.toString(),
      'rooms_count': rooms_count.toString(),
      'bathrooms_count': bathrooms_count.toString(),
      'province_id': province.id.toString(),
      'property_type': property_type,
      'balconies_count': balconies_count.toString(),
      'has_roof': has_roof ? '1' : '0',
      'floor': floor,
      'has_electricity_meter': has_electricity_meter ? '1' : '0',
      'has_water_counter': has_water_counter ? '1' : '0',
      'is_furnished': is_furnished ? '1' : '0',
      'has_solar_energy': has_solar_energy ? '1' : '0',
      'is_deluxe': is_deluxe ? '1' : '0',
    };


    try {
      // 2. استدعاء API مع الحقلين المنفصلين
      final response = await Api().postMultipart(
        url: '$kBaseUrl/apartments',
        fields: fields,
        files: additionalImages, // ✅ الصور الإضافية
        fileFieldName: 'images[]', // ✅ الحقل للصور الإضافية
        mainImage: mainImage, // ✅ الصورة الرئيسية (مطلوبة)
        mainImageFieldName: 'main_image', // ✅ حقل الصورة الرئيسية
        token: token,
        typeLanguage: currentLanguage.currentLanguage.value,
      );

      return response;
    } catch (e) {
      print("❌ خطأ في إضافة الشقة: $e");
      rethrow;
    }
  }
}