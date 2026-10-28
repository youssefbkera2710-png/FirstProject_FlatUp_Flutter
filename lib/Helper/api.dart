import 'dart:convert';
import 'dart:io';

import 'package:flat_up/Helper/apiException.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Api {
  Future<dynamic> get({
    required String url,
    @required String? token,
    @required String? typeLanguage,
  }) async {
    Map<String, String> headers = {};
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    if (typeLanguage == 'en' || typeLanguage == 'ar') {
      headers.addAll({'X-App-Locale': '$typeLanguage'});
    }
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    Map<String, dynamic> data = jsonDecode(response.body);

    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data; // نجاح
      } else {
        String message =
            data['message']?.toString() ?? 'Request failed (success=false)';

        // ✅ إذا فيه errors، جمعها برسالة وحدة
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          String errorMessages = '';

          errors.forEach((key, value) {
            if (value is List) {
              for (var msg in value) {
                errorMessages += "$msg\n";
              }
            }
          });

          message = errorMessages.trim().isNotEmpty
              ? errorMessages.trim()
              : message;
        }

        // ✅ ارمي ApiException مع الرسالة + الداتا
        throw ApiException(message, data);
      }
    } else {
      throw Exception('Invalid response: success key is missing');
    }
  }

  Future<dynamic> post({
    required String url,
    @required dynamic body,
    @required String? token,
    @required String? typeLanguage,
  }) async {
    Map<String, String> headers = {};
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    if (typeLanguage == 'en' || typeLanguage == 'ar') {
      headers.addAll({'X-App-Locale': '$typeLanguage'});
    }

    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: headers,
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data; // نجاح
      } else {
        String message =
            data['message']?.toString() ?? 'Request failed (success=false)';

        // ✅ إذا فيه errors، جمعها برسالة وحدة
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          String errorMessages = '';

          errors.forEach((key, value) {
            if (value is List) {
              for (var msg in value) {
                errorMessages += "$msg\n";
              }
            }
          });

          message = errorMessages.trim().isNotEmpty
              ? errorMessages.trim()
              : message;
        }

        // ✅ ارمي ApiException مع الرسالة + الداتا
        throw ApiException(message, data);
      }
    } else {
      throw Exception('Invalid response: success key is missing');
    }
  }



Future<dynamic> postMultipart({
  required String url,
  required Map<String, String> fields,
  List<File> files = const [], // ✅ تغيير الاسم للوضوح
  String fileFieldName = 'images[]',
  File? mainImage,
  String mainImageFieldName = 'main_image',
  required String? token,
  required String? typeLanguage,
}) async {
  var request = http.MultipartRequest("POST", Uri.parse(url));
  
  request.fields.addAll(fields);


  // 1. إضافة الصور الإضافية (جديدة + قديمة إذا احتاج الأمر)
  for (var file in files) {
    request.files.add(
      await http.MultipartFile.fromPath(fileFieldName, file.path),
    );
    print("➕ إضافة صورة إضافية: ${file.path}");
  }

  // 2. إضافة الصورة الرئيسية (مطلوبة في حالة الإضافة، اختيارية في التعديل)
  if (mainImage != null) {
    request.files.add(
      await http.MultipartFile.fromPath(mainImageFieldName, mainImage.path),
    );
    print("⭐ إرسال الصورة الرئيسية: ${mainImage.path}");
  }

  // Headers
  if (token != null && token.isNotEmpty) {
    request.headers['Authorization'] = 'Bearer $token';
  }
  if (typeLanguage == 'en' || typeLanguage == 'ar') {
    request.headers['X-App-Locale'] = typeLanguage!;
  }
  request.headers['Accept'] = 'application/json';

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  print("📥 الاستجابة: $responseBody");
  
  Map<String, dynamic> data = jsonDecode(responseBody);

  if (data is Map && data.containsKey('success')) {
    if (data['success'] == true) {
      return data;
    } else {
      String message =
          data['message']?.toString() ?? 'Request failed (success=false)';

      if (data.containsKey('errors')) {
        final errors = data['errors'];
        String errorMessages = '';

        errors.forEach((key, value) {
          if (value is List) {
            for (var msg in value) {
              errorMessages += "$msg\n";
            }
          }
        });

        message = errorMessages.trim().isNotEmpty
            ? errorMessages.trim()
            : message;
      }

      throw ApiException(message, data);
    }
  } else {
    throw Exception('Invalid response: success key is missing');
  }
}


  Future<dynamic> put({
    required String url,
    @required dynamic body,
    @required String? token,
    @required String? typeLanguage,
  }) async {
    Map<String, String> headers = {};
    headers.addAll({'Content-Type': 'application/x-www-form-urlencoded'});
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }
    if (typeLanguage == 'en' || typeLanguage == 'ar') {
      headers.addAll({'X-App-Locale': '$typeLanguage'});
    }
    http.Response response = await http.post(
      Uri.parse(url),
      body: body,
      headers: headers,
    );
    Map<String, dynamic> data = jsonDecode(response.body);

    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data; // نجاح
      } else {
        String message =
            data['message']?.toString() ?? 'Request failed (success=false)';

        // ✅ إذا فيه errors، جمعها برسالة وحدة
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          String errorMessages = '';

          errors.forEach((key, value) {
            if (value is List) {
              for (var msg in value) {
                errorMessages += "$msg\n";
              }
            }
          });

          message = errorMessages.trim().isNotEmpty
              ? errorMessages.trim()
              : message;
        }

        // ✅ ارمي ApiException مع الرسالة + الداتا
        throw ApiException(message, data);
      }
    } else {
      throw Exception('Invalid response: success key is missing');
    }
  }

  Future<dynamic> delete({
    required String url,
    @required String? token,
    @required String? typeLanguage,
  }) async {
    Map<String, String> headers = {};
    // التوكن
    if (token != null) {
      headers.addAll({'Authorization': 'Bearer $token'});
    }

    // اللغة
    if (typeLanguage == 'en' || typeLanguage == 'ar') {
      headers.addAll({'X-App-Locale': '$typeLanguage'});
    }

    // طلب DELETE
    http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if (data is Map && data.containsKey('success')) {
      if (data['success'] == true) {
        return data; // نجاح
      } else {
        String message =
            data['message']?.toString() ?? 'Request failed (success=false)';

        // ✅ إذا فيه errors، جمعها برسالة وحدة
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          String errorMessages = '';

          errors.forEach((key, value) {
            if (value is List) {
              for (var msg in value) {
                errorMessages += "$msg\n";
              }
            }
          });

          message = errorMessages.trim().isNotEmpty
              ? errorMessages.trim()
              : message;
        }

        // ✅ ارمي ApiException مع الرسالة + الداتا
        throw ApiException(message, data);
      }
    } else {
      throw Exception('Invalid response: success key is missing');
    }
  }
}
