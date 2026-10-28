
import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PostUpdateApartmentServices {
  // دالة لتحميل الصورة من رابط وتحويلها إلى ملف (للصورة الرئيسية فقط)
  Future<File?> _downloadImage(String imageUrl) async {
    try {

      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');
        
        await file.writeAsBytes(response.bodyBytes);

        return file;
      }
    } catch (e) {
      print("❌ خطأ في تحميل الصورة: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> updateApartment({
    required int apartmentId,
    required String title,
    required String description,
    required double area,
    required String rentType,
    required String city,
    required double price,
    required int roomsCount,
    required int bathroomsCount,
    required ProvinesModels province,
    required String propertyType,
    required int balconiesCount,
    required bool hasRoof,
    required String floor,
    required bool hasElectricityMeter,
    required bool hasWaterCounter,
    required bool isFurnished,
    required bool hasSolarEnergy,
    required bool isDeluxe,
    required String? oldMainImageUrl, // رابط الصورة الرئيسية القديمة (قد يكون null إذا حذفها المستخدم)
    required List<String> oldAdditionalImages, // روابط الصور الإضافية القديمة التي نريد الاحتفاظ بها
    required File? newMainImage, // الصورة الرئيسية الجديدة (اختياري)
    required List<File> newAdditionalImages, // الصور الإضافية الجديدة
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();

    // 1. إعداد الحقول النصية
    Map<String, String> fields = {
      '_method': 'POST',
      'title': title,
      'description': description,
      'area': area.toString(),
      'rent_type': rentType,
      'city': city,
      'price': price.toString(),
      'rooms_count': roomsCount.toString(),
      'bathrooms_count': bathroomsCount.toString(),
      'province_id': province.id.toString(),
      'property_type': propertyType,
      'balconies_count': balconiesCount.toString(),
      'has_roof': hasRoof ? '1' : '0',
      'floor': floor,
      'has_electricity_meter': hasElectricityMeter ? '1' : '0',
      'has_water_counter': hasWaterCounter ? '1' : '0',
      'is_furnished': isFurnished ? '1' : '0',
      'has_solar_energy': hasSolarEnergy ? '1' : '0',
      'is_deluxe': isDeluxe ? '1' : '0',
    };

    File? mainImageFile;

    // 2. معالجة الصور الرئيسية
    if (newMainImage != null) {
      // ✅ حالة: إرسال صورة رئيسية جديدة
      mainImageFile = newMainImage;
    } else if (oldMainImageUrl != null && oldMainImageUrl.isNotEmpty) {
      // ✅ حالة: الإبقاء على الصورة الرئيسية القديمة (تحميلها وإرسالها كملف)
      mainImageFile = await _downloadImage(oldMainImageUrl);

    }

    // 3. إضافة روابط الصور الإضافية القديمة التي نريد الاحتفاظ بها كـ old_images[]
    for (int i = 0; i < oldAdditionalImages.length; i++) {
      fields['old_images[$i]'] = oldAdditionalImages[i];
    }


    try {
      // 4. استدعاء API مع الحقلين المنفصلين
      final response = await Api().postMultipart(
        url: '$kBaseUrl/apartments/$apartmentId',
        fields: fields,
        files: newAdditionalImages, // ✅ نرسل فقط الصور الإضافية الجديدة
        fileFieldName: 'new_images[]', // ✅ الحقل للصور الإضافية الجديدة
        mainImage: mainImageFile, // ✅ الحقل للصورة الرئيسية (قد يكون null)
        mainImageFieldName: 'main_image', // ✅ اسم حقل الصورة الرئيسية
        token: token,
        typeLanguage: currentLanguage.currentLanguage.value,
      );


      return response;
    } catch (e) {
      print("❌ خطأ في استدعاء API: $e");
      rethrow;
    }
  }
}