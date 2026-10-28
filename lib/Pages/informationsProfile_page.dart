import 'dart:io';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/apiException.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/textNumber.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Models/provines_models.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:flat_up/Servicse/getAllProvines_services.dart';
import 'package:flat_up/Servicse/getMyProfile_services.dart';
import 'package:flat_up/Servicse/getProfileStatus_services.dart';
import 'package:flat_up/Servicse/postUpdateProfile_services.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textfiled_widget.dart';
import 'package:flat_up/widget/datePickerFormField.dart';
import 'package:flat_up/widget/dropSellectProvines.dart';
import 'package:flat_up/widget/profileImageFormField.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformationsprofilePage extends StatefulWidget {
  const InformationsprofilePage({Key? key}) : super(key: key);
  static String id = 'InformationsprofilePage';

  @override
  State<InformationsprofilePage> createState() =>
      _InformationsprofilePageState();
}

class _InformationsprofilePageState extends State<InformationsprofilePage> {
  final _formKey = GlobalKey<FormState>();
  // bool isEditable = true; // تتحكم بالتعديل
  String? userStatus;
  UserModels? _user;
  String? profileImageUrl;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  bool isFetchingProfile = false;
  bool isSubmitting = false;
  File? profileImage;
  DateTime? selectedBirthDate;
  int? selectedProvinceId;
  ProvinesModels? _selectedProvince;
  List<ProvinesModels> backendProvinces = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      final fromNotification = args?['fromNotification'] == true;

      if (fromNotification) {
        checkStatus(); // 🔥 refresh تلقائي
      }
    });

    _initData();
  }

  Future<void> _initData() async {
    await _loadUserFromPrefs();
    await loadProfileFromUser();
    await _loadProvinces();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> checkStatus() async {
    final localization = LocalizationService.of(context);

    setState(() => isFetchingProfile = true);
    try {
      final result = await GetprofilestatusServices().getStatus();

      final status = result['pending_approval']['status'];
      if (status == "rejected") {
        final reason = result['pending_approval']['reason'];
        await getMyInformations();
        await _loadProvinces();
        await loadProfileFromUser();
        SnackBarWidget(
          context,
          '${localization.translate('rejectChanges')} $reason ',
          SnackType.error,
        );
      } else if (status == "pending") {
        SnackBarWidget(
          context,
          localization.translate('pendingChanges'),
          SnackType.warning,
        );
      } else if (status == "approved") {
        SnackBarWidget(
          context,
          localization.translate('approvedChanges'),
          SnackType.success,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localization.translate('noChangesSent')),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    }
    setState(() => isFetchingProfile = false);
  }

  Future<void> getMyInformations() async {
    try {
      final user = await GetmyprofileServices().getProfile();
      setState(() {
        _user = user;
      });
      await _saveApprovedProfileLocally();
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _saveApprovedProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null)
      return;
    else {
      await prefs.setString('first_name', _user!.firstName ?? '');
      await prefs.setString('last_name', _user!.lastName ?? '');
      await prefs.setString('city', _user!.city ?? '');
      await prefs.setString('phone', _user!.phoneNumber ?? '');
      await prefs.setString('national_id', _user!.nationalId ?? '');
      await prefs.setString(
        'profile_image_url',
        // _user!.profileImageUrl ?? '',
        _user!.profileImageUrl ?? '',
      );
      await prefs.setString('profile_image', _user!.profileImage ?? '');
      if (_user?.birthDate != null) {
        await prefs.setString(
          'birth_date',
          DateFormat('yyyy-MM-dd').format(_user!.birthDate!),
        );
      }

      if (_user?.provinceId != null) {
        await prefs.setInt('province_id', _user!.provinceId!);
      }
      await prefs.setString('province_name', _user!.provinceName ?? '');
    }
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _user = UserModels(
      firstName: prefs.getString('first_name'),
      lastName: prefs.getString('last_name'),
      city: prefs.getString('city'),
      phoneNumber: prefs.getString('phone'),
      nationalId: prefs.getString('national_id'),
      profileImageUrl: prefs.getString('profile_image_url'),
      provinceId: prefs.getInt('province_id'),
      provinceName: prefs.getString('province_name'),
      birthDate: prefs.getString('birth_date') != null
          ? DateTime.parse(prefs.getString('birth_date')!)
          : null,
    );
  }

  Future<void> loadProfileFromUser() async {
    isFetchingProfile = true;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // _firstNameController.text = prefs.getString('first_name') ?? '';
      // _lastNameController.text = prefs.getString('last_name') ?? '';
      // _cityController.text = prefs.getString('city') ?? '';
      // _phoneController.text = prefs.getString('phone') ?? '';
      // _nationalIdController.text = prefs.getString('national_id') ?? '';
      // provinceNameController.text = prefs.getString('province_name') ?? '';
      // final birthDateStr = prefs.getString('birth_date');
      // if (birthDateStr != null) {
      //   selectedBirthDate = DateTime.parse(birthDateStr);
      // }
      // final approvedProvinceId = prefs.getInt('province_id');
      // if (approvedProvinceId != null && backendProvinces.isNotEmpty) {
      //   _selectedProvince = backendProvinces.firstWhere(
      //     (p) => p.id == approvedProvinceId,
      //     orElse: () => backendProvinces.first,
      //   );
      // }
      final imageUrl = prefs.getString('profile_image_url');
      profileImageUrl = (imageUrl != null && imageUrl.isNotEmpty)
          ? imageUrl
          : null;
      _firstNameController.text = _user?.firstName ?? 'FirstName';
      _lastNameController.text = _user?.lastName ?? 'LastName';
      _cityController.text = _user?.city ?? 'City';
      _phoneController.text = _user?.phoneNumber ?? 'PhoneNumber';
      _nationalIdController.text = _user?.nationalId ?? 'NationaId';
      if (_user?.birthDate != null) {
        final birthDateStr = DateFormat('yyyy-MM-dd').format(_user!.birthDate!);
        selectedBirthDate = DateTime.parse(birthDateStr);
      }
      final approvedProvinceId = _user?.provinceId ?? null;
      if (approvedProvinceId != null && backendProvinces.isNotEmpty) {
        _selectedProvince = backendProvinces.firstWhere(
          (p) => p.id == approvedProvinceId,
          orElse: () => backendProvinces.first,
        );
      }
    });
  }

  bool _birthDateChanged() {
    if (selectedBirthDate == null || _user == null) return false;
    final userDate = _user!.birthDate!;
    return selectedBirthDate!.year != userDate.year ||
        selectedBirthDate!.month != userDate.month ||
        selectedBirthDate!.day != userDate.day;
  }

  bool _phoneChanged() {
    final current = _phoneController.text.replaceAll(' ', '');
    return current != _user!.phoneNumber;
  }

  bool hasChanges() {
    if (_user == null) return false;
    return _firstNameController.text != _user!.firstName ||
        _lastNameController.text != _user!.lastName ||
        _cityController.text != (_user!.city ?? '') ||
        _phoneChanged() ||
        _nationalIdController.text != _user!.nationalId ||
        _birthDateChanged() ||
        _selectedProvince?.id != _user!.provinceId ||
        profileImage != null;
  }

  Future<void> _showConfirmSubmitDialog() async {
    final localization = LocalizationService.of(context);

    final isDark = Provider.of<Themes>(context, listen: false).isDark;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // المستخدم لازم يختار
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(localization.translate('confirmSubmitTitle')),
          content: Text(localization.translate('confirmSubmitContent')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                localization.translate('cancel'),
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? kPrimaryColorDark1
                    : kPrimaryColorLight1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localization.translate('ok'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _submitProfile(); // تنفيذ الإرسال
    }
  }

  Future<void> _loadProvinces() async {
    setState(() {
      isFetchingProfile = true;
      backendProvinces = [];
    });

    try {
      final list = await GetallprovinesServices().getProvines();
      final approvedProvinceId = _user?.provinceId ?? null;

      setState(() {
        backendProvinces = list;

        if (approvedProvinceId != null && backendProvinces.isNotEmpty) {
          _selectedProvince = backendProvinces.firstWhere(
            (p) => p.id == approvedProvinceId,
            orElse: () => backendProvinces.first,
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading provinces: $e');
      setState(() {
        backendProvinces = [
          ProvinesModels(
            id: _user?.provinceId ?? 0,
            name: _user?.provinceName ?? 'محافظتك',
          ),
        ];
      });
    } finally {
      setState(() {
        isFetchingProfile = false;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSubmitting = true;
        isFetchingProfile = true;
      });
      try {
        if (_user == null) return;
        final result = await PostupdateprofileServices().updateProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          city: _cityController.text,
          phone: _phoneController.text.replaceAll(' ', ''),
          date: DateFormat('yyyy-MM-dd').format(selectedBirthDate!),
          governorateId: int.parse(_selectedProvince!.id.toString()),
          nationalid: _nationalIdController.text,
          profileImages: profileImage != null ? [profileImage!] : [],
        );
        _user = UserModels.fromJson(result['user']);
        await _saveApprovedProfileLocally();
        loadProfileFromUser();
        SnackBarWidget(context, result['message'], SnackType.waitting);
      } on ApiException catch (e) {
        final message = e.message;
        SnackBarWidget(context, message, SnackType.error);
      } catch (e) {
        SnackBarWidget(
          context,
          e.toString().replaceAll('Exception: ', ''),
          SnackType.error,
        );
      } finally {
        // إعادة الزر والمؤشر لحالتهم الطبيعية
        setState(() {
          isSubmitting = false;
          isFetchingProfile = false;
        });
      }
    } else {
      SnackBarWidget(context, 'أكمل البيانات الناقصة !', SnackType.warning);
    }
  }

  @override
  Widget build(BuildContext context) {
    LocalizationService localization = LocalizationService.of(context);
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(icon: const Icon(Icons.refresh), onPressed: checkStatus),
        // ],
        backgroundColor: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
        title: Text(localization.translate('profileTitle')),
        centerTitle: true,
      ),
      body: isFetchingProfile
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: RefreshIndicator(
                    onRefresh: checkStatus,
                    color: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 12),
                        const SizedBox(height: 20),
                        ProfileImageFormField(
                          imageUrl: profileImageUrl,
                          onSaved: (file) => profileImage = file,
                          onChanged: (file) {
                            setState(() {
                              profileImage = file; // تحديث فورّي للمتغير
                            });
                          },
                        ),

                        const SizedBox(height: 40),
                        CostumTextfiledWidget(
                          controller: _firstNameController,
                          prefixIcon: Icons.person,
                          hintText: localization.translate('first_name'),
                        ),
                        const SizedBox(height: 12),

                        CostumTextfiledWidget(
                          controller: _lastNameController,
                          prefixIcon: Icons.person_outline,
                          hintText: localization.translate('last_name'),
                        ),
                        const SizedBox(height: 12),

                        CostumTextfiledWidget(
                          controller: _cityController,
                          prefixIcon: Icons.location_city,
                          hintText: localization.translate('city'),
                        ),
                        const SizedBox(height: 12),

                        CostumTextfiledWidget(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [Textnumber(maxDigits: 10)],
                          prefixIcon: Icons.phone,
                          hintText: localization.translate('phone_num'),
                        ),

                        const SizedBox(height: 12),
                        CostumTextfiledWidget(
                          controller: _nationalIdController,
                          prefixIcon: Icons.account_box,
                          isNationalId: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            Textnumber(maxDigits: 11, enableFormat: false),
                          ],
                          hintText: localization.translate('national_id'),
                        ),

                        const SizedBox(height: 12),
                        // Birth date
                        DatePickerFormField(
                          initialValue: selectedBirthDate,
                          onSaved: (date) => selectedBirthDate = date,
                          onChanged: (date) {
                            // هذا السطر
                            setState(() {
                              selectedBirthDate = date;
                            });
                          },
                        ),

                        const SizedBox(height: 12),
                        // Province selector
                        Dropsellectprovines(
                          labelText: localization.translate('province'),
                          selectedValue: _selectedProvince,
                          items: backendProvinces,
                          onSelected: (value) {
                            setState(() {
                              _selectedProvince = value;
                            });
                          },
                          onSaved: (value) => _selectedProvince = value,
                        ),

                        const SizedBox(height: 24),

                        Align(
                          child: CostumButtonWidget(
                            onTap: () {
                              if (isSubmitting)
                                return; // تمنع الضغط أثناء الإرسال

                              if (hasChanges()) {
                                _showConfirmSubmitDialog(); // هذا سيستدعي _submitProfile()
                              } else {
                                SnackBarWidget(
                                  context,
                                  localization.translate('noDataChanged'),
                                  SnackType.warning,
                                );
                              }
                            },

                            namebutton: isSubmitting
                                ? localization.translate('loading')
                                : localization.translate('edit'),
                            width: 250,
                            colorDecoration: isSubmitting
                                ? Colors.grey
                                : (isDark
                                      ? kPrimaryColorDark1
                                      : kPrimaryColorLight1),
                            colorText: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
