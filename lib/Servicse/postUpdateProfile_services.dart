import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class PostupdateprofileServices {
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String city,
    required String phone,
    required String date,
    required int governorateId,
    required String nationalid,
    required List<File> profileImages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? "";
    HomeController currentLanguage =
        Get.find<
          HomeController
        >();
    final data = await Api().postMultipart(
      url: '$kBaseUrl/profile/update',
      fields: {
        'first_name': firstName,
        'last_name': lastName,
        'city': city,
        'phone_number': phone,
        'birth_date': date,
        'province_id': governorateId.toString(),
        'national_id': nationalid,
      },
      files: profileImages,
      fileFieldName: 'profile_image',
      token: token,
      typeLanguage: currentLanguage
          .currentLanguage
          .value,
    );
    return data;
  }
}
