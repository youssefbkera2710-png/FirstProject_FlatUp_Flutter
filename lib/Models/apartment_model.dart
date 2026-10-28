import 'dart:convert';

import 'package:flat_up/Models/provines_models.dart';

class User {
  final int? id;
  final String? name;
  final String? profile;

  User({this.id, this.name, this.profile});

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return User(id: null, name: null, profile: null);
    }
    return User(
      id: json['id']?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      profile: json['profile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'profile': profile};
}

class ApartmentModel {
  final int id;
  final String title;
  final String description;
  final String mainImage;
  final double area;
  final String city;
  final int roomsCount;
  final int bathroomsCount;
  final int? balconiesCount;
  final bool hasRoof;
  final bool hasElectricityMeter;
  final bool hasWaterCounter;
  final bool hasSolarEnergy;
  final bool isFurnished;
  final bool isDeluxe;
  final String propertyType;
  final int? floor;
  final ProvinesModels province;
  final List<ApartmentImage> images;
  final String createdAt;
  final double? averageRating;
  // الحقول الجديدة
  final double? price;
  final String? rentType;
  final String? status;
  final User? user;
  final List<dynamic>? availableDateRanges;
  final String ?reject_message;

  ApartmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.mainImage,
    required this.area,
    required this.city,
    required this.roomsCount,
    required this.bathroomsCount,
    required this.balconiesCount,
    required this.hasRoof,
    required this.hasElectricityMeter,
    required this.hasWaterCounter,
    required this.hasSolarEnergy,
    required this.isFurnished,
    required this.isDeluxe,
    required this.propertyType,
    required this.floor,
    required this.province,
    required this.images,
    required this.createdAt,
    required this.averageRating,
    required this.price,
    required this.rentType,
    required this.status,
    required this.user,
    required this.availableDateRanges,
    required this.reject_message
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لتحويل أي قيمة إلى String
    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        // إذا كانت القيمة Map، حاول استخراج قيمة نصية منها
        if (value.containsKey('ar') || value.containsKey('en')) {
          // إذا كانت تحتوي على ترجمة
          return value['ar']?.toString() ?? value['en']?.toString() ?? '';
        }
        return value.toString();
      }
      return value.toString();
    }

    // دالة مساعدة لتحويل أي قيمة إلى double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // دالة مساعدة لتحويل أي قيمة إلى int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    // دالة مساعدة لتحويل أي قيمة إلى bool
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    // معالجة images
    List<ApartmentImage> parseImages(dynamic value) {
      if (value is List) {
        return value.map((item) {
          if (item is Map<String, dynamic>) {
            return ApartmentImage(
              path: parseString(item['path']),
              isMain: parseBool(item['is_main']),
            );
          } else if (item is String) {
            return ApartmentImage(path: item, isMain: false);
          }
          return ApartmentImage(path: '', isMain: false);
        }).toList();
      }
      return [];
    }

    // معالجة province
    ProvinesModels parseProvince(dynamic value) {
      if (value is Map<String, dynamic>) {
        return ProvinesModels(
          id: parseInt(value['id']) ?? 0,
          name: parseString(value['name']),
        );
      }
      return ProvinesModels(id: 0, name: '');
    }

    // معالجة user - مهم: قد يكون null
    User? parseUser(dynamic value) {
      if (value != null && value is Map<String, dynamic>) {
        return User.fromJson(value);
      }
      return null;
    }

    return ApartmentModel(
      id: parseInt(json['id']) ?? 0,
      title: parseString(json['title']),
      description: parseString(json['description']),
      mainImage: parseString(json['main_image']),
      area: parseDouble(json['area']),
      city: parseString(json['city']),
      roomsCount: parseInt(json['rooms_count']) ?? 0,
      bathroomsCount: parseInt(json['bathrooms_count']) ?? 0,
      balconiesCount: parseInt(json['balconies_count']),
      hasRoof: parseBool(json['has_roof']),
      hasElectricityMeter: parseBool(json['has_electricity_meter']),
      hasWaterCounter: parseBool(json['has_water_counter']),
      hasSolarEnergy: parseBool(json['has_solar_energy']),
      isFurnished: parseBool(json['is_furnished']),
      isDeluxe: parseBool(json['is_deluxe']),
      propertyType: parseString(json['property_type']),
      floor: parseInt(json['floor']),
      province: parseProvince(json['province']),
      images: parseImages(json['images']),
      createdAt: parseString(json['created_at']),
      averageRating: json['average_rating'] != null
          ? parseDouble(json['average_rating'])
          : null,
      // تحميل الحقول الجديدة - قد تكون null
      price: parseDouble(json['price']),
      rentType: json['rent_type']?.toString(),
      status: json['status']?.toString(),
      user: parseUser(json['user']),
      availableDateRanges: json['available_date_ranges'] is List
          ? json['available_date_ranges']
          : null,
          reject_message:  parseString(json['reject_message'])
    );
  }

  // دالة مساعدة لتحويل السعر إلى صيغة مقروءة
  String get formattedPrice {
    try {
      if (price == null) {
        print('⚠️ السعر غير متوفر أو فارغ');
        return 'غير محدد';
      }
      double priceValue = double.tryParse(price.toString()) ?? 0;
      if (priceValue >= 1000000) {
        return '${(priceValue / 1000000).toStringAsFixed(2)}m';
      } else if (priceValue >= 1000) {
        return '${(priceValue / 1000).toStringAsFixed(1)}k';
      } else {
        return '$priceValue';
      }
    } catch (e) {
      print('❌ خطأ في تحويل السعر: $e');
      return price.toString();
    }
  }

  // دالة للتحقق من وجود سعر
  bool get hasPrice => price != null;

  // دالة للتحقق من وجود مالك
  bool get hasUser =>
      user != null && user!.name != null && user!.name!.isNotEmpty;
}

class ApartmentImage {
  final String path;
  final bool isMain;

  ApartmentImage({required this.path, required this.isMain});
}
