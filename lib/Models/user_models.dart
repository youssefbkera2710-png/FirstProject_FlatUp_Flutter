class UserModels {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? nationalId;
  String? profileImage;
  String? profileImageUrl;
  DateTime? birthDate;
  String? provinceName;
  int? provinceId;
  String? city;
  String? role;
  String? status;

  UserModels({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.nationalId,
    this.profileImage,
    this.profileImageUrl,
    required this.birthDate,
    this.provinceName,
    this.city,
    this.role,
    this.provinceId,
    this.status,
  });
  factory UserModels.fromJson(Map<String, dynamic> json) {
    return UserModels(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      nationalId: json['national_id'],
      profileImage: json['profile_image'],
      profileImageUrl: json['profile_image_url'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      provinceName: json['province'],
      provinceId: json['province_id'] is int
          ? json['province_id']
          : int.tryParse(json['province_id'].toString()),
      city: json['city'],
      role: json['role'],
      status: json['status'],
    );
  }
}
