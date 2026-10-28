import 'dart:io';
import 'package:flat_up/Pages/login_page.dart';
import 'package:flat_up/Pages/waiting_page.dart';
import 'package:flat_up/widget/datePickerFormField.dart';
import 'package:flat_up/widget/dropSellectProvines.dart';
import 'package:flat_up/widget/profileImageFormField.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flat_up/Helper/localization_service.dart';

import '../Models/provines_models.dart';
import '../Servicse/getAllProvines_services.dart';
import '../Servicse/postCompleteProfile_services.dart';

import '../widget/costum_textfiled_widget.dart';
import '../widget/costum_button_widget.dart';
import '../widget/snackBar_widget.dart';
import '../Helper/themes.dart';
import '../constants/elementConstant.dart';

class CompleteprofilePage extends StatefulWidget {
  CompleteprofilePage({super.key});
  static String id = 'CompleteprofilePage';

  @override
  State<CompleteprofilePage> createState() => _CompleteprofilePageState();
}

class _CompleteprofilePageState extends State<CompleteprofilePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;
  late LocalizationService localizations;

  // form values
  File? _profileImage;
  DateTime? _birthDate;
  ProvinesModels? _selectedProvince;
  final TextEditingController _cityController = TextEditingController();

  // provinces list
  List<ProvinesModels> backendProvinces = [];

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = LocalizationService.of(context);
  }

  Future<void> _loadProvinces() async {
    setState(() {
      backendProvinces = [];
      isLoading = true;
      errorMessage = null; // مسح أي رسالة خطأ سابقة
    });

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw SocketException(localizations.translate('noInternet'));
      }

      final list = await GetallprovinesServices().getProvines();

      if (list.isEmpty) {
        throw Exception(localizations.translate('noData'));
      }

      setState(() {
        backendProvinces = list;
      });
    } catch (e) {
      debugPrint('${localizations.translate('errorLoadingProvinces')} $e');
      setState(() {
        backendProvinces = [];
        errorMessage = localizations.translate('noInternetOrError');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });
    try {
      final result = await PostcompleteprofileServices().completeProfile(
        governorateId: _selectedProvince!.id,
        city: _cityController.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_birthDate!),
        profileImages: [_profileImage!],
      );

      final bool isComplete = result['user']['is_profile_complete'];
      final role = result['user']['role'];
      final status = result['user']['status'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_profile_complete', isComplete);
      await prefs.setString('role', role);
      await prefs.setString('status', status);
      await prefs.setString('step', 'waiting_approval');

      SnackBarWidget(context, result['message'], SnackType.waitting);
      print(result);
      Navigator.pushReplacementNamed(context, WaitingPage.id);
    } catch (e) {
      SnackBarWidget(
        context,
        e.toString().replaceAll('Exception: ', ''),
        SnackType.error,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  } /////////////////////////////////////////////////

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final localizations = LocalizationService.of(context);

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(localizations.translate('completeProfile')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                Navigator.pushReplacementNamed(context, LoginPage.id);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('email');
                await prefs.remove('token');
                await prefs.remove('is_profile_complete');
                await prefs.remove('step');
                await prefs.remove('status');
                await prefs.remove('role');
              },
            ),
            backgroundColor: isDark ? kPrimaryColorDark1 : kPrimaryColorLight1,
            centerTitle: true,
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          localizations.translate('profileImage'),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Profile image
                    ProfileImageFormField(
                      initialValue: _profileImage,
                      onSaved: (file) => _profileImage = file,
                      validator: (file) {
                        if (file == null)
                          return localizations.translate(
                            'profileImageRequired',
                          );
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('birthDate'),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Birth date
                    DatePickerFormField(
                      label: localizations.translate('birthDate'),
                      initialValue: _birthDate,
                      onSaved: (date) => _birthDate = date,
                      onChanged: (date) {
                        // هذا السطر
                        setState(() {
                          _birthDate = date;
                        });
                      },
                      validator: (date) {
                        if (date == null)
                          return localizations.translate('birthDateRequired');
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('enterCity'),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // City text field
                    CostumTextfiledWidget(
                      hintText: localizations.translate('city'),
                      prefixIcon: Icons.location_city,
                      controller: _cityController,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate('enterProvince'),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Province selector
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: _loadProvinces, // يعيد تحميل المحافظات
                              icon: Icon(Icons.refresh, color: Colors.white),
                              label: Text(
                                localizations.translate('tryAgain'),
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Dropsellectprovines(
                        labelText: localizations.translate('province'),
                        selectedValue: _selectedProvince,
                        items: backendProvinces,
                        onSelected: (value) {
                          setState(() {
                            _selectedProvince = value;
                          });
                        },
                        onSaved: (value) => _selectedProvince = value,
                      ),

                    const SizedBox(height: 40),

                    // Submit button
                    Align(
                      child: CostumButtonWidget(
                        onTap: _submitProfile,
                        namebutton: localizations.translate('submit'),
                        width: 250,
                        colorDecoration: isDark
                            ? kPrimaryColorDark1
                            : kPrimaryColorLight1,
                        colorText: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
