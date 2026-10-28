import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/apiException.dart';
import 'package:flat_up/Models/user_models.dart';
import 'package:flat_up/Pages/completeProfile_Page.dart';
import 'package:flat_up/Pages/forgetPassword_page.dart';
import 'package:flat_up/Pages/homeVendor_page.dart';
import 'package:flat_up/Pages/verify_page.dart';
import 'package:flat_up/Pages/waiting_page.dart';
import 'package:flat_up/Servicse/fcm_api.dart';
import 'package:flat_up/Servicse/fcm_service.dart';
import 'package:flat_up/Servicse/postLogin_servicse.dart';
import 'package:flat_up/widget/button_iconTheme_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';
import 'package:flat_up/Pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'LoginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserModels? _user;
  Future<void> _saveApprovedProfileLocally() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user == null)
      return;
    else {
      await prefs.setInt('id', _user!.id!);
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

  String? email;
  String? password;
  final GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final colors = Theme.of(context).colorScheme;
    final FocusNode firstNode = FocusNode();
    final FocusNode secondNode = FocusNode();
    LocalizationService localization = LocalizationService.of(context);
    HomeController homeController = Get.find<HomeController>();
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(kLogoApp, width: 120, height: 100),
          const SizedBox(height: 8),
          const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? Colors.transparent
            : const Color.fromARGB(255, 255, 255, 255),
        body: CustomScrollView(
          slivers: [
            /// ------------------- الجزء العلوي -------------------
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// 🖼️ صورة الخلفية
                    Image.asset(
                      isDark ? kloginDark : kLoginLight,
                      fit: BoxFit.cover,
                    ),

                    Positioned(
                      top: 30, // نزّلها أو ارفعها حسب الذوق
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            ButtonIconthemeWidget(),

                            const SizedBox(width: 6),

                            IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.language,
                                color: isDark ? Colors.grey : Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                homeController.changeLanguage();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// ------------------- الكونتينر الأبيض -------------------
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  // vertical: 20,
                ),

                decoration: BoxDecoration(
                  color: colors.onPrimary,
                  // borderRadius: const BorderRadius.only(
                  //   topLeft: Radius.circular(40),
                  //   topRight: Radius.circular(40),
                  // ),
                ),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 25),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      children: [
                        Text(
                          localization.translate('login_title'),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 📧 Email
                        CostumTextfiledWidget(
                          hintText: localization.translate('email_hint'),
                          keyboardType: TextInputType.emailAddress,
                          currentFocus: firstNode,
                          nextFocus: secondNode,
                          prefixIcon: Icons.email_rounded,
                          onChanged: (value) => email = value,
                        ),

                        const SizedBox(height: 12),

                        /// 🔐 Password
                        CostumTextfiledWidget(
                          hintText: localization.translate('password_hint'),
                          currentFocus: secondNode,
                          nextFocus: null,
                          prefixIcon: Icons.lock_rounded,
                          obscureText: hidePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                          onChanged: (value) => password = value,
                        ),

                        const SizedBox(height: 25),

                        Align(
                          child: CostumButtonWidget(
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() => isLoading = true);

                                try {
                                  final result = await PostloginServicse()
                                      .loginUser(
                                        email: email!,
                                        password: password!,
                                      );
                                  ////////////////////////// بروفايل

                                  setState(() {
                                    _user = UserModels.fromJson(
                                      result['data']['user'],
                                    );
                                  });
                                  ////////////////////////// بروفايل
                                  ///
                                  // final fcmToken =
                                  //     await FcmService.getFcmToken();
                                  // if (fcmToken != null) {
                                  //   await FcmApi().sendTokenToBackend(fcmToken);
                                  // }

                                  final role = result['data']['user']['role'];
                                  final step = result['data']['user']['step'];
                                  final token = result['data']['token'];

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('email', email!);
                                  await prefs.setString('step', step);
                                  await prefs.setString('role', role);
                                  await prefs.setString('token', token);
                                  await _saveApprovedProfileLocally();

                                  final message =
                                      result['message']?.toString() ?? '';
                                  if (message.isNotEmpty) {
                                    SnackBarWidget(
                                      context,
                                      message,
                                      SnackType.success,
                                    );
                                  }
                                  Navigator.pushReplacementNamed(
                                    context,
                                    HomevendorPage.id,
                                  );
                                } on ApiException catch (e) {
                                  final data = e.data ?? {};
                                  final step = data['step']?.toString() ?? '';
                                  final token = data['token']?.toString();
                                  final role = data['role']?.toString();
                                  final message = e.message;
                                  SnackBarWidget(
                                    context,
                                    message,
                                    SnackType.error,
                                  );
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString('email', email!);
                                  if (step.isNotEmpty) {
                                    await prefs.setString('step', step);
                                  }
                                  if (token != null && token.isNotEmpty) {
                                    await prefs.setString('token', token);
                                  }
                                  print('hahah  : $token');
                                  if (role != null && role.isNotEmpty) {
                                    await prefs.setString('role', role);
                                  }
                                  await Future.delayed(
                                    const Duration(milliseconds: 300),
                                  );

                                  switch (step.trim()) {
                                    case 'complete_profile':
                                      Navigator.pushReplacementNamed(
                                        context,
                                        CompleteprofilePage.id,
                                      );

                                      break;
                                    case 'waiting_approval':
                                      Navigator.pushReplacementNamed(
                                        context,
                                        WaitingPage.id,
                                      );
                                      break;
                                    case 'verify_email':
                                      Navigator.pushReplacementNamed(
                                        context,
                                        VerifyPage.id,
                                      );
                                    default:
                                      print('Unknown step: "$step"');
                                  }
                                } catch (e) {
                                  SnackBarWidget(
                                    context,
                                    e.toString().replaceAll('Exception: ', ''),
                                    SnackType.error,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              }
                            },
                            namebutton: localization.translate('sign_in'),
                            width: 250,
                            colorDecoration: isDark
                                ? kPrimaryColorDark1
                                : kPrimaryColorLight1,
                            colorText: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localization.translate('no_account'),
                              style: TextStyle(
                                color: isDark
                                    ? kPrimaryColorDark1
                                    : kPrimaryColorLight1,
                                fontSize: 16,
                              ),
                            ),
                            Text('   '),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, RegisterPage.id);
                              },
                              child: Text(
                                localization.translate('register'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ForgetpasswordPage.id,
                              );
                            },
                            child: Text(
                              localization.translate('forgot_password'),

                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: colors.primary,
                                color: isDark
                                    ? kSecondaryColorDark
                                    : kSecondaryColorLight,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 200),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
