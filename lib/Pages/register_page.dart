import 'package:flat_up/Controller/home_controller.dart';
import 'package:flat_up/Helper/apiException.dart';
import 'package:flat_up/Helper/localization_service.dart';
import 'package:flat_up/Helper/themes.dart';
import 'package:flat_up/Helper/textNumber.dart';
import 'package:flat_up/Pages/verify_page.dart';
import 'package:flat_up/Servicse/postRegister_services.dart';
import 'package:flat_up/widget/button_iconTheme_widget.dart';
import 'package:flat_up/widget/radioChoose_widget.dart';
import 'package:flat_up/widget/snackBar_widget.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:flat_up/constants/elementConstant.dart';
import 'package:flat_up/widget/costum_button_widget.dart';
import 'package:flat_up/widget/costum_textFiled_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

//بدي اسوي شغلة تفضاية البيانات من conroller

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String id = 'RegisterPage';
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? firstName;
  String? lastName;
  String? numberPhone;
  String? nationalId;
  String? email;
  String? password;
  String? role;
  bool hidePassword = true;

  GlobalKey<FormState> formKey = GlobalKey();
  bool isLoading = false;
  HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    LocalizationService localization = LocalizationService.of(context);
    final colors = Theme.of(context).colorScheme;
    final themeController = Provider.of<Themes>(context);
    final isDark = themeController.isDark;
    final FocusNode firstNode = FocusNode();
    final FocusNode secondNode = FocusNode();
    final FocusNode thirdNode = FocusNode();
    final FocusNode fourNode = FocusNode();
    final FocusNode fiveNode = FocusNode();
    final FocusNode sixNode = FocusNode();

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            /// ------------------- الجزء العلوي -------------------
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 260,
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

                            const SizedBox(height: 12),

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
                  // borderRadius: BorderRadius.only(
                  //   topLeft: Radius.circular(40),
                  //   topRight: Radius.circular(40),
                  // ),
                ),

                child: Form(
                  key: formKey,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 2),
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        localization.translate('register'),
                        style: TextStyle(
                          fontSize: 30,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// -------- First - Last Name --------
                      Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: CostumTextfiledWidget(
                              hintText: localization.translate('first_name'),
                              currentFocus: firstNode,
                              nextFocus: secondNode,
                              prefixIcon: Icons.person,
                              onChanged: (data) => firstName = data,
                            ),
                          ),
                          const Spacer(flex: 2),
                          SizedBox(
                            width: 180,
                            child: CostumTextfiledWidget(
                              hintText: localization.translate('last_name'),
                              currentFocus: secondNode,
                              nextFocus: thirdNode,
                              prefixIcon: Icons.person_outline,
                              onChanged: (data) => lastName = data,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// -------- Phone - National ID --------
                      Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: CostumTextfiledWidget(
                              hintText: localization.translate('phone_num'),
                              currentFocus: thirdNode,
                              nextFocus: fourNode,
                              prefixIcon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [Textnumber(maxDigits: 10)],
                              onChanged: (value) {
                                numberPhone = value.replaceAll(' ', '');
                              },
                            ),
                          ),
                          const Spacer(flex: 2),
                          SizedBox(
                            width: 180,
                            child: CostumTextfiledWidget(
                              hintText: localization.translate('national_id'),
                              currentFocus: fourNode,
                              nextFocus: fiveNode,
                              prefixIcon: Icons.account_box,
                              isNationalId: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                Textnumber(maxDigits: 11, enableFormat: false),
                              ],
                              onChanged: (value) {
                                nationalId = value;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// -------- Email --------
                      CostumTextfiledWidget(
                        hintText: localization.translate('email_hint'),
                        currentFocus: fiveNode,
                        nextFocus: sixNode,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        onChanged: (value) {
                          email = value;
                        },
                      ),

                      const SizedBox(height: 10),

                      /// -------- Password --------
                      CostumTextfiledWidget(
                        hintText: localization.translate('password_hint'),
                        currentFocus: sixNode,
                        nextFocus: null,
                        prefixIcon: Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
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

                      const SizedBox(height: 15),

                      /// -------- Radio --------
                      RadiochooseWidget(
                        onSelected: (value) {
                          role = value;
                        },
                      ),

                      const SizedBox(height: 30),

                      /// -------- Register Button --------
                      Align(
                        child: CostumButtonWidget(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              isLoading = true;
                              setState(() {});
                              try {
                                final result = await PostregisterServices()
                                    .addUser(
                                      firstName: firstName!,
                                      lastName: lastName!,
                                      email: email!,
                                      password: password!,
                                      phoneNumber: numberPhone!,
                                      nationalid: nationalId!,
                                      role: role!,
                                    );
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('email', email!);

                                SnackBarWidget(
                                  context,
                                  result['message'],
                                  SnackType.success,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VerifyPage(localization: localization),
                                  ),
                                );
                              } on ApiException catch (e) {
                                final message = e.message;
                                SnackBarWidget(
                                  context,
                                  message,
                                  SnackType.warning,
                                );
                              } catch (e) {
                                SnackBarWidget(
                                  context,
                                  e.toString().replaceAll('Exception: ', ''),
                                  SnackType.error,
                                );
                              }

                              isLoading = false;
                              setState(() {});
                            }
                          },
                          namebutton: localization.translate('register'),
                          width: 250,
                          colorDecoration: isDark
                              ? kPrimaryColorDark1
                              : kPrimaryColorLight1,
                          colorText: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 22),

                      /// -------- Already Have Account --------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localization.translate('already_have_acc'),
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
                              Navigator.pop(context);
                            },
                            child: Text(
                              localization.translate('login_title'),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
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
