import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostcompleteprofileServices {
  Future<Map<String, dynamic>> completeProfile({
    required int governorateId,
    required String city,
    required String date,
    required List<File> profileImages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    final currentLanguage = Get.find<HomeController>();

    return await Api().postMultipart(
      url: '$kBaseUrl/complete-profile',
      fields: {
        'province_id': governorateId.toString(),
        'city': city,
        'birth_date': date,
      },
      files: profileImages,
      fileFieldName: 'profile_image',
      token: token,
      typeLanguage: currentLanguage.currentLanguage.value,
    );
  }
}
